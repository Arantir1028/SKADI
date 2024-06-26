#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import grpc
import os
import csv
import logging
import numpy as np

from pkg.option import RunConfig
from pkg.utils import Query
from pkg.loadbalancer.base import LoadBalancer

import pkg.service_pb2 as service_pb2
import pkg.service_pb2_grpc as service_pb2_grpc


class ClockLoadBalancer(LoadBalancer):
    def __init__(
        self, loader_id, run_config: RunConfig, model_id, query_q, node_q, qos_target
    ) -> None:
        super().__init__(
            run_config=run_config,
            model_id=model_id,
            query_q=query_q,
            qos_target=qos_target,
        )
        self._node_q = node_q
        self._loader_id = loader_id

    def run(self) -> None:
        self._channel_dict = {}
        self._stub_dict = {}
        self._node_list = []
        log_path = "results/cluster/" + self._run_config.policy
        log_dir = os.path.join(self._run_config.path, log_path)
        os.makedirs(log_dir, exist_ok=True)
        self._serve_combination = self._run_config.serve_combination
        result_fname = "{}_{}.csv".format(
            self._run_config.models_name[self._model_id], self._loader_id
        )
        self._result_path = os.path.join(log_dir, result_fname)
        self._result_file = open(self._result_path, "w+")
        self._wr = csv.writer(self._result_file, dialect="excel")
        result_header = ["query_id", "model_id",
                         "bs", "seq_len", "load_id", "latency"]
        self._wr.writerow(result_header)
        self._result_file.flush()
        for node_id in range(self._run_config.node_cnt):
            ip = self._run_config.ip_dict[node_id]
            channel = grpc.insecure_channel("{}:50051".format(ip))
            stub = service_pb2_grpc.DNNServerStub(channel=channel)
            self._channel_dict[node_id] = channel
            self._stub_dict[node_id] = stub
            self._node_list.append(node_id)
        while True:
            # logging.info("hello")
            if not self._query_q.empty():
                query: Query = self._query_q.get()
                headroom = query.get_headromm() / 1000
                if headroom > 0:
                    try:
                        node_id = self._node_q.get(
                            block=True, timeout=headroom)
                        logging.debug("node: {} scheduled".format(node_id))
                        result = self._stub_dict[node_id].Inference(
                            service_pb2.Query(
                                id=query.id,
                                model_id=query.model_id,
                                bs=query.batch_size,
                                seq_len=query.seq_len,
                                start_stamp=query.start_stamp,
                                qos_target=query.qos_targt,
                                load_id=query.load_id,
                            )
                        )
                        elapsed = result.elapsed
                        idle_node_id = result.node_id
                        self._node_q.put(idle_node_id)
                        logging.debug(
                            "idle node: {} push back".format(node_id))
                        self._wr.writerow(
                            np.array(
                                [
                                    query.id,
                                    query.model_id,
                                    query.batch_size,
                                    query.seq_len,
                                    query.load_id,
                                    elapsed,
                                ]
                            )
                        )
                    except Exception as error:
                        logging.debug(
                            "timeout for query id: {}".format(query.id))
                        self._wr.writerow(
                            np.array(
                                [
                                    query.id,
                                    query.model_id,
                                    query.batch_size,
                                    query.seq_len,
                                    query.load_id,
                                    -1,
                                ]
                            )
                        )
                else:
                    logging.debug("drop for query id: {}".format(query.id))
                    self._wr.writerow(
                        np.array(
                            [
                                query.id,
                                query.model_id,
                                query.batch_size,
                                query.seq_len,
                                query.load_id,
                                -1,
                            ]
                        )
                    )
                self._result_file.flush()
