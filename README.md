# PasseiDireto
Repositório para armazenar o conteúdo do teste técnico da vaga de infraestrutura

Este repositório possui uma estrutura com dois diretório
- docker: nesse diretório existem 3 subdiretórios, um para cada serviço (MySQL, NodeJS e Nginx), em cada subdiretório existem os arquivos necessários para a criação de cada imagem de cada serviço.
- exec: nesse diretório tem um script em bash que faz todo o gerenciamento do ambiente, abaixo explicarei como o script funciona

#### Pré-requistos:
Para rodar os serviços é necessário possuir uma máquina Linux ou MacOS com docker instalado e configurado

#### Disclaimer: 
Esse amabiente não foi testado em Windows

#### Funcionamento:
O ambiente é gerenciando por um único script em Bash, que possui as seguintes funcionalidades:
- Criar imagens
- Remover imagens
- Criar ou iniciar os containers dos serviços
- Parar os containers dos serviços
- Remover os containers dos serviços
- Remover as imagens
- Testar a aplicação  

#### Usando o ambiente:
1. Clonar o repositório:  
$ git clone https://github.com/edugdias/passeidireto.git
2. Posicionar-se no diretório "exec" no repositório:  
$ cd passeidireto/exec
3. Executar o script de gerenciamento:  
$ ./manage_services.sh --help  
A saída apresentará os comando disponíveis para a execução do gerenciamento:  
Use:  
manage_services.sh --help: mostra esse help  
manage_services.sh --build: gera as imagens dos serviços  
manage_services.sh --delete-image: remove as imagens e os containers dos serviços  
manage_services.sh --delete-container: remove as imagens e os containers dos serviços  
manage_services.sh --run: inicia os três serviços  
manage_services.sh --stop: para os três serviços  
manage_services.sh --test: para os três serviços  

- Criando imagens:  
$ ./manage_services.sh --build
- Iniciando os serviços:  
$ ./manage_services.sh --run
- Testando os serviços:  
$ ./manage_services.sh --test
- Parando os serviços:  
$ ./manage_services.sh --stop
- Removendo os containers:  
$ ./manage_services.sh --delete-container
- Removendo as imagens:  
$ ./manage_services.sh --delete-images
