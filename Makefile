docker-run:
	docker run -p 8010:8010 hello_java .

docker-build:
	docker build -t registry.cn-zhangjiakou.aliyuncs.com/develop_bigbigliu/hello_java:v1 .

run:
	mvn spring-boot:run