# O que é o Docker?
O Docker é um projeto de software livre para automatizar a implantação de aplicativos como contêineres autossuficientes portáteis que podem ser executados na nuvem ou localmente.

Contêineres do Docker podem executar em qualquer lugar, localmente no datacenter do cliente, em um provedor de serviços externo ou na nuvem, na AWS.

Ao usar o Docker, você não escutará os desenvolvedores dizerem "Funciona no meu computador, por que não em produção?".
Eles podem simplesmente dizer: "É executado no Docker", porque o aplicativo empacotado do Docker pode ser executado em qualquer ambiente do Docker compatível, sendo executado da maneira pretendida em todos os destinos de implantação.

Maiores benefícios de usar o Docker : 
- Facilita a criação e a execução de arquiteturas de microsserviços distribuídos.
- Implanta o código com pipelines de integração e entrega contínuos padronizados.
- Cria sistemas de processamento de dados altamente escaláveis.
- Constrói plataformas totalmente gerenciadas para os desenvolvedores.

# Qual é a diferença entre o Docker e uma máquina virtual?
As máquinas virtuais incluem o aplicativo, as bibliotecas ou binários necessários e um sistema operacional convidado completo. A virtualização completa requer mais recursos do que a conteinerização.


Como os contêineres requerem muito menos recursos (por exemplo, eles não precisam de um sistema operacional completo), eles iniciam rapidamente e são fáceis de implantar.

Isso permite que você tenha maior densidade, o que significa que permite a você executar mais serviços na mesma unidade de hardware, reduzindo os custos.

# O que é AWS?
Em 2006, a Amazon Web Services (AWS) começou a oferecer serviços de infraestrutura de TI para empresas por meio de serviços web - hoje conhecidos como computação em nuvem. 

Um dos principais benefícios da computação em nuvem é a oportunidade de substituir diretamente gastos com a infraestrutura principal por preços variáveis baixos, que se ajustam de acordo com sua empresa. 

Com a Nuvem, as empresas não precisam mais planejar ou adquirir servidores, assim como outras infraestruturas de TI, com semanas ou meses de antecedência. 

Em vez disso, podem instantaneamente rodar centenas de milhares de servidores em minutos e oferecer resultados mais rapidamente.

# Como o Docker funciona junto com a AWS?
Os seguintes serviços da AWS facilitam a execução e o gerenciamento de contêineres do Docker em escala :
- AWS Fargate - tecnologia para o Amazon ECS que permite executar contêineres em produção sem implantar ou gerenciar a infraestrutura.
- Amazon ECS - serviço de gerenciamento de contêiner altamente escalável e de alta performance.
- Amazon EKS - facilita a execução do Kubernetes na AWS.
- AWS Batch - permite executar cargas de trabalho de processamento em lote altamente escaláveis usando contêineres do Docker.
- Amazon ECR - é um repositório privado de imagens altamente disponível e seguro que facilita o armazenamento e o gerenciamento de imagens do contêiner do Docker.

# Parte 1 - Conteinerizando um Website com o Docker e Rodando um Web-Server com o NGINX
Suponhamos que temos em mãos um arquivo index.html que funciona como uma página estática estruturada com HTML, estilizada com CSS e parametrizada com Javascript.

Podemos hospedar nosso website em um web-server e rodá-lo localmente com  o NGINX, logo, o mesmo pode ser configurado para rodar em um contêiner.

Fazemos isso através do Dockerfile, um arquivo responsável por realizar a criação e construção de imagens no Docker, dentro dele são definidas instruções que o Docker deve seguir para conseguir realizar a criação de uma imagem. 

Essas instruções são interpretadas linha a linha pelo motor do Docker :

```

# use nginx:alpine as base image
FROM nginx:alpine
LABEL MAINTAINER="Gabriel"
# copy static website index.html into nginx default html folder
COPY index.html /usr/share/nginx/html
# export port 80
EXPOSE 80
# run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

```
O NGINX por padrão, ao ser inicializado roda o arquivo index.html presente dentro da pasta localizada no path /usr/share/nginx/html.

Então ao copiar nosso site para dentro desta pasta, ele entende que esse é o site a ser inicializado por padrão ao acessar o caminho http://localhost/.

E agora, como podemos criar a nossa imagem a partir do Dockerfile? Para isso vamos utilizar o comando docker build .
Passamos como parâmetro o valor -t seguido pelo nome da imagem que pretendemos criar, e por último um . (local onde se localiza o Dockerfile).

```

$ docker build -t html-server:v1 .

```

Após rodar o comando build , uma imagem com nome html-server será criada.

Com a imagem criada, podemos construir nosso contêiner e subir o nosso website :

```

$ docker run -d -p 80:80 html-server:v1

```

Podemos testar nosso deploy acessando http://localhost e ver nosso arquivo index.html sendo mostrado.
