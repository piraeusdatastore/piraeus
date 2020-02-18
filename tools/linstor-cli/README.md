# Faster CLI

## Method 1: kubectl exec

```
kubectl -n kube-system exec -it piraeus-controller-0 -- linstor $@
```

> This method only works where kubectl is set up.

## Method 2: docker run

```
docker run --rm -it \
    -e LS_CONTROLLERS=${LS_CONTROLLERS} \
    -v /etc/linstor:/etc/linstor:ro \
    quay.io/piraeusdatastore/piraeus-client \
    $@
```
> This method copies image at each linstor command, which causes a lot of overhead in terms of speed.

## Method 3: runc run

* linstor.runc-run.sh

> This method utilizes RunC to run piraeus-client container. It only extracts image by docker when called for the first time. After that, docker does not involve in any execution.

## Speed test

Test shows RunC is the fastest method, even faster than kubectl exec.

| Method                   | Speed |
| :------------------------|:------|
| # in controller pod      | 0.25s |
| runc run                 | 0.32s |
| kubectl exec             | 0.49s |
| docker run               | 1.98s |

> Result by averaging 10 executions of `linstor node list`