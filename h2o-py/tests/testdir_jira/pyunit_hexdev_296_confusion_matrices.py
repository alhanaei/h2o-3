import sys
sys.path.insert(1, "../../")
import h2o

def confusion_matrices_check(ip, port):
    h2o.init(ip, port)

    local_data = [[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[1, 'a'],[0, 'b'],
                  [0, 'b'],[0, 'b'],[0, 'b'],[0, 'b'],[0, 'b'],[0, 'b'],[0, 'b'],[0, 'b'],[0, 'b']]
    h2o_data = h2o.H2OFrame(python_obj=local_data)
    h2o_data.setNames(['response', 'predictor'])
    h2o_data.show()

    gbm = h2o.gbm(x=h2o_data[1:], y=h2o_data["response"].asfactor(), ntrees=1, distribution="bernoulli")
    gbm.show()
    perf = gbm.model_performance()
    tps = perf.metric("tps", [perf.find_threshold_by_max_metric("f1")])[0][1]
    tns = perf.metric("tns", [perf.find_threshold_by_max_metric("f1")])[0][1]
    fps = perf.metric("fps", [perf.find_threshold_by_max_metric("f1")])[0][1]
    fns = perf.metric("fns", [perf.find_threshold_by_max_metric("f1")])[0][1]

    assert tps + tns + fps + fns == 20, "incorrect confusion matrix computation: tps: {0}, fps: {1}, tns: {2}, fns: " \
                                        "{3}. Should sum to 20.".format(tps, fps, tns, fns)

if __name__ == "__main__":
    h2o.run_test(sys.argv, confusion_matrices_check)
