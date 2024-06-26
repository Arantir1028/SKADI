#!/usr/bin/env python3
# -*- coding:utf-8 -*-


import os
import logging
import numpy as np
from torch.multiprocessing import Process
import torch
import torch.nn as nn
from torch.cuda.streams import Stream

from pkg.worker.base import AbacusWorker


class ServerWorker(AbacusWorker):
    def __init__(
        self,
        run_config,
        model_name: str,
        supported_batchsize,
        supported_seqlen,
        recv_pipe,
        barrier,
        warmup_barrier,
        worker_id,
    ):
        super().__init__(
            run_config,
            model_name,
            supported_batchsize,
            supported_seqlen,
            recv_pipe,
            worker_id,
        )
        self._barrier = barrier
        self._warmup_barrier = warmup_barrier

    def run(self) -> None:
        logging.info("Server woker for {} starting".format(self._model_name))
        os.environ["CUDA_MPS_ACTIVE_THREAD_PERCENTAGE"] = "100"
        if self._mig != 0:
            os.environ["CUDA_MPS_PIPE_DIRECTORY"] = self._mps_pipe_dirs[self._mig][
                self._worker_id
            ]
            os.environ["CUDA_MPS_LOG_DIRECTORY"] = self._mps_log_dirs[self._mig][
                self._worker_id
            ]
            os.environ["CUDA_VISIBLE_DEVICES"] = self._mps_devices[self._mig][
                self._worker_id
            ]
        else:
            os.environ["CUDA_MPS_PIPE_DIRECTORY"] = "/tmp/nvidia-mps"
            os.environ["CUDA_MPS_LOG_DIRECTORY"] = "/tmp/nvidia-log"
            os.environ[
                "CUDA_VISIBLE_DEVICES"
            ] = str(self._device)

        torch.device("cuda:{}".format(self._device))
        torch.backends.cudnn.enabled = True

        if self._model_name == "inception_v3":
            self._inputs = {
                k: torch.rand(k, 3, 299, 299).half().cuda(self._device)
                for k in self._supported_batchsize
            }
        elif self._model_name == "bert":
            self._inputs = {
                k: {
                    seqlen: torch.LongTensor(np.random.rand(k, seqlen, 768))
                    .half()
                    .cuda(self._device)
                    for seqlen in self._supported_seqlen
                }
                for k in self._supported_batchsize
            }
            self._masks = {
                k: {
                    seqlen: torch.LongTensor(np.zeros((k, 1, 1, seqlen)))
                    .half()
                    .cuda(self._device)
                    for seqlen in self._supported_seqlen
                }
                for k in self._supported_batchsize
            }
        else:
            self._inputs = {
                k: torch.rand(k, 3, 224, 224).half().cuda(self._device)
                for k in self._supported_batchsize
            }

        self._model = self._model_func().half().cuda(self._device).eval()

        if self._model_name != "bert":
            self._submodules = self._model.get_submodules()
            self._total_module = len(self._submodules)

        self._stream = Stream(0)
        self._event = torch.cuda.Event(enable_timing=False)

        logging.info("Server Woker for {} warming".format(self._model_name))
        with torch.cuda.stream(self._stream):
            for k in self._supported_batchsize:
                if self._model_name == "bert":
                    for seqlen in self._supported_seqlen:
                        self._model.run(
                            self._inputs[k][seqlen], self._masks[k][seqlen], 0, 12
                        )
                else:
                    self._model(self._inputs[k])

        torch.cuda.synchronize()
        self._warmup_barrier.wait()
        with torch.no_grad():
            while True:
                (
                    query_id,
                    action,
                    barrier_id,
                    start,
                    end,
                    bs,
                    seq_len,
                ) = self._pipe.recv()
                if action == "new":
                    # logging.info(
                    #     "Worker: {} processing New Query: {} {} {} {}".format(
                    #         self._worker_id, query_id, start, end, bs
                    #     )
                    # )
                    if self._model_name == "bert":
                        self._inter_input = self._model.run(
                            self._inputs[bs][seq_len], self._masks[bs][seq_len], 0, end
                        )
                    else:
                        submodel = nn.Sequential(*self._submodules[:end])
                        self._inter_input = submodel(self._inputs[bs])
                    torch.cuda.synchronize()
                    self._barrier[barrier_id].wait()

                elif action == "inter":
                    # logging.info(
                    #     "Worker: {} processing Inter Query: {} {} {} {}".format(
                    #         self._worker_id, query_id, start, end, bs
                    #     )
                    # )
                    if self._model_name == "bert":
                        self._inter_input = self._model.run(
                            self._inter_input, self._masks[bs][seq_len], start, end
                        )
                    else:
                        submodel = nn.Sequential(*self._submodules[start:end])
                        self._inter_input = submodel(self._inter_input)
                    torch.cuda.synchronize()
                    self._barrier[barrier_id].wait()

                elif action == "terminate":
                    logging.info(
                        "Terminating server worker: {}".format(self._worker_id)
                    )
                    break
                else:
                    logging.error(
                        "Not supported action {} for worker{}".format(
                            action, self._model_name
                        )
                    )
                    raise NotImplementedError
