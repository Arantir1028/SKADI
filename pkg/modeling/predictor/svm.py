#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import numpy as np

from sklearn.svm import LinearSVR
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

from pkg.modeling.dataloader import load_data_for_sklearn
from pkg.modeling.predictor import LatencyPredictor
from pkg.option import RunConfig


class SVMPredictor(LatencyPredictor):
    def __init__(
        self,
        run_config: RunConfig,
        models_id,
        epoch=30,
        batch_size=16,
        data_fname=None,
        split_ratio=0.8,
        path="/home/cwh/Lego",
        total_models=2,
        mig=0,
    ):
        super().__init__(
            run_config,
            "svm",
            models_id,
            epoch,
            batch_size,
            data_fname,
            split_ratio,
            path,
            total_models,
            mig=mig,
        )

    def train(self, save_result=False, save_model=False, perf=False):
        trainX, trainY, testX, testY = load_data_for_sklearn(
            self._data_fname, self._split_ratio, self._models_id, self._data_path
        )
        regr = make_pipeline(
            StandardScaler(), LinearSVR(random_state=0, tol=1e-5))
        # self._model = regr
        print(trainX)
        print(trainY)
        print(len(trainX))
        print(len(trainY))
        regr.fit(trainX, trainY)

        pred = regr.predict(testX)

        e = pred - testY
        mae = np.average(np.abs(e))
        mape = np.average(np.abs(e) / testY)
        print(mae)
        print(mape)
        if save_result is True:
            self.save_result(combination=self._data_fname, mae=mae, mape=mape)
