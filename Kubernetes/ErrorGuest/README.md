# This is a configuration that fails on purpose, the error is easy to spot though. For training.

## One liner deployment`:
`kubectl apply -f  frontend.yaml && kubectl apply -f redis-master.yaml && kubectl apply -f redis-slave.yaml`
