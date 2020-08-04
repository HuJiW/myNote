Dockerfile 是一个用来构建镜像的文本文件
  FROM：定制的镜像都是基于 FROM 的镜像
  
  RUN：用于执行后面跟着的命令行命令
    RUN <命令行命令>
    RUN ["可执行文件", "参数1", "参数2"]
    
  && 符号连接命令，这样执行后，只会创建 1 层镜像
  
  COPY
    COPY [--chown=<user>:<group>] <源路径1>...  <目标路径>
    COPY [--chown=<user>:<group>] ["<源路径1>",...  "<目标路径>"]
    [--chown=<user>:<group>]：可选参数，用户改变复制到容器内文件的拥有者和属组。
 
   ADD
     和 COPY 的使用格式一致（同样需求下，官方推荐使用 COPY）。功能也类似，不同之处如下：
     优点：在执行 <源文件> 为 tar 压缩文件的话，压缩格式为 gzip, bzip2 以及 xz 的情况下，会自动复制并解压到 <目标路径>。
     缺点：在不解压的前提下，无法复制 tar 压缩文件。会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。具体是否使用，可以根据是否需要自动解压来决定。

  CMD
      类似于 RUN 指令，用于运行程序，但二者运行的时间点不同:
      CMD 在docker run 时运行。如果存在多个 CMD 指令，仅最后一个生效。
      RUN 是在 docker build。

  ENV
    设置环境变量，定义了环境变量，那么在后续的指令中，就可以使用这个环境变量。
    ENV <key> <value>
    ENV <key1>=<value1> <key2>=<value2>...
    
  VOLUME
    定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷。
    避免重要的数据，因容器重启而丢失，这是非常致命的。
    避免容器不断变大。
    VOLUME ["<路径1>", "<路径2>"...]
    VOLUME <路径>
  
  EXPOSE
    声明端口。
    帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射。
    在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口。
    EXPOSE <端口1> [<端口2>...]

  WORKDIR
      指定工作目录。用 WORKDIR 指定的工作目录，会在构建镜像的每一层中都存在。（WORKDIR 指定的工作目录，必须是提前创建好的）。
      docker build 构建镜像过程中的，每一个 RUN 命令都是新建的一层。只有通过 WORKDIR 创建的目录才会一直存在。
      WORKDIR <工作目录路径>
      
  USER
      用于指定执行后续命令的用户和用户组，这边只是切换后续命令执行的用户（用户和用户组必须提前已经存在）。
      USER <用户名>[:<用户组>]    
      
docker build -t nginx:test .   #通过目录下的 Dockerfile 构建一个 nginx:test（镜像名称:镜像标签）,最后的 . 代表本次执行的上下文路径


Docker Compose
      用于定义和运行多容器 Docker 应用程序的工具。通过 Compose，您可以使用 YML 文件来配置应用程序需要的所有服务。然后，使用一个命令，就可以从 YML 文件配置中创建并启动所有服务。
      使用的三个步骤：
          1. 使用 Dockerfile 定义应用程序的环境。
          2. 使用 docker-compose.yml 定义构成应用程序的服务，这样它们可以在隔离环境中一起运行。
          3. 最后，执行 docker-compose up 命令来启动并运行整个应用程序。
    
  Dockerfile 配置文件
        FROM python:3.7-alpine   #从 Python 3.7 映像开始构建镜像。
        WORKDIR /code            #将工作目录设置为 /code  
        ENV FLASK_APP app.py     #设置 flask 命令使用的环境变量
        ENV FLASK_RUN_HOST 0.0.0.0
        RUN apk add --no-cache gcc musl-dev linux-headers    # 安装 gcc，以便诸如 MarkupSafe 和 SQLAlchemy 之类的 Python 包可以编译加速。
        COPY requirements.txt requirements.txt    #复制 requirements.txt 并安装 Python 依赖项。
        RUN pip install -r requirements.txt
        COPY . .
        CMD ["flask", "run"]

  docker-compose.yml 配置文件
        # yaml 配置   定义了两个服务：web 和 redis
        version: '3'
        services:
          web:      #从 Dockerfile 当前目录中构建的镜像
            build: .
            ports:
             - "5000:5000"
          redis:     #使用 Docker Hub 的公共 Redis 映像
            image: "redis:alpine"
            
  执行以下命令来启动应用程序：docker-compose up
  如果你想在后台执行该服务可以加上 -d 参数：docker-compose up -d            
            


volumes
    将主机的数据卷或着文件挂载到容器里。
    version: "3.7"
    services:
      db:
        image: postgres:latest
        volumes:
          - "/localhost/postgres.sock:/var/run/postgres/postgres.sock"
          - "/localhost/data:/var/lib/postgresql/data"
          
         
