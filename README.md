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

# Parte 2 — Construindo a Infraestrutura da Nuvem (Usuário IAM, Repositório ECR, ECS Cluster, Task Definitions e Services)
Nosso workflow vai consistir de construir e enviar uma imagem de nosso contêiner ao ECR e fazer o deploy de uma nova task definition para o ECS quando uma release da aplicação for criada.

Para enviar uma imagem docker a um repositório do ECR na AWS, devemos ter um ambiente configurado e permissão para acessar seus recursos.

Ou seja, a primeira coisa que devemos fazer é criar o repositório para armazenar nossas imagens Docker.

**Como criar um repositório de imagens ECR**
Um repositório é o local em que armazena as imagens do Docker ou da Open Container Initiative (OCI) no Amazon ECR.
Sempre que enviar ou receber uma imagem do Amazon ECR, especifique o repositório e o local do registro, que informa para onde enviar a imagem ou de onde retirá-la.

- Abra o console do Amazon ECR em https://console.aws.amazon.com/ecr/.
- Escolha Get Started.
- Em Tag immutability (Imutabilidade de tag), escolha a configuração de mutabilidade de tag para o repositório. Repositórios configurados com tags imutáveis - impedirão que as tags de imagens sejam substituídas.
- Em Scan on push (Verificar ao enviar), escolha a configuração de verificação de imagem para o repositório. Os repositórios configurados para verificar ao enviar iniciarão uma verificação de imagem sempre que uma imagem for enviada, caso contrário, as verificações de imagem deverão ser iniciadas manualmente. Para obter mais informações, consulte Verificação de imagens.
- Escolha Create repository (Criar repositório).

Após criar o repositório, devemos verificar se nossa conta possui acesso.

Caso esteja usando um usuário root, esse acesso é garantido por padrão por pertencer à lista de políticas AdministratorAccess, mas isso não é recomendado.

A melhor prática é criar um usuário IAM para acessar o serviço e conceder a este usuário as permissões necessárias para usar o ECR.

**Criando um usuário IAM**
Entre no console do IAM como o proprietário da conta escolhendo usuário raiz e inserindo o endereço de e-mail de sua da conta AWS. Na próxima página, insira sua senha.

- No painel de navegação, escolha Usuários e depois Adicionar usuário.
- Em Set permissions (Conceder permissões), escolha Add user to group (Adicionar usuário ao grupo).
- Escolha Create group (Criar grupo).
- Escolha Filter policies (Filtrar políticas) para filtrar o conteúdo de tabelas.
- Na lista de políticas, marque a caixa de seleção que se refere ao ECR. A seguir escolha Criar grupo.
- Quando você estiver pronto para continuar, selecione Criar usuário.

Você pode usar esse mesmo processo para criar mais grupos e usuários e conceder aos seus usuários acesso aos recursos de sua conta da AWS.

Ao ter em mãos o ambiente e acesso administrativo aos repositórios da ECR, é possível fazer o push de qualquer imagem do docker através de uma pipeline ou pelo console através de linhas de comando.

**Criando um ECS Cluster**
O Amazon Elastic Container Service (Amazon ECS) é o serviço da Amazon Web Services que você usa para executar aplicativos do Docker em um cluster escalável.
O assistente de primeira execução do Amazon ECS orientará você durante a criação de um cluster e a execução de um aplicativo web de exemplo através do seguinte passo-a-passo.

- Configure sua primeira execução com o Amazon ECS.
- Crie uma definição de tarefa.
- Configure seu serviço.
- Configure seu cluster.

**Parte 3 — Implementando uma Pipeline CI/CD com o Github Actions**
Nesse projeto, vamos utilizar de um build e deploy automatizado através de uma pipeline CI/CD criada através do Github Actions.
O seguinte template pode ser utilizado como modelo base para fazer o deploy de uma aplicação ao ECR e ECS.

```

on:
  release:
    types: [created]
name: Deploy to Amazon ECS
jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production
steps:
    - name: Checkout
      uses: actions/checkout@v2
- name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-2
- name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
- name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: my-ecr-repo
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
- name: Fill in the new image ID in the Amazon ECS task definition
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: task-definition.json
        container-name: sample-app
        image: ${{ steps.build-image.outputs.image }}
- name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: sample-app-service
        cluster: default
        wait-for-service-stability: true

```

Para uso do template, as seguintes mudanças devem ser feitas para o encaixe da aplicação :

- Substituir o valor de ECR_REPOSITORY no fluxo de trabalho pelo nome do seu repositório.
- Substituir o valor de aws-region no fluxo de trabalho abaixo pela região do seu repositório.
- Substituir os valores de service e cluster no fluxo de trabalho pelos seus nomes de serviço e cluster.
- Substituir o valor de task-definition no fluxo de trabalho pelo nome do seu arquivo JSON presente no repositório.
- Substituir o valor de container-name no fluxo de trabalho pelo nome do contêiner.
- Armazenar uma chave de acesso de usuário IAM nos segredos do GitHub como variáveis chamadas AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY.

# Parte 4 — Acesso à aplicação através de um IP Público disponibilizado pela AWS
Ao finalizar a pipeline, nossa integração entre o repositório e a nuvem está completa. Sendo assim, essa última etapa é apenas a verificação do website através de um endereço de IP público.

Você pode usar o console do Amazon EC2 para visualizar os endereços IPv4 privados, os endereços IPv4 públicos e os endereços IP elásticos das instâncias.

Você também pode determinar os endereços IPv4 públicos e privados da instância usando os metadados da instância.

