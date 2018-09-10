#!/bin/bash
#
# Este script faz o gerenciamento dos serviços de Nginx, MySQL e NodeJS
#
# A execução do script suporta:
# - a criação das três imagens de uma única vez ou das que faltam
# - a remoção das três imagens e de containers de uma única vez ou das que existem
# - iniciar os três serviços de uma única vez
# - parar os três serviços de uma única vez
# - testar a aplicação
# 
# Obs: 
# - 
#
# TODO:
# - incluir opção para criar, remover, iniciar, parar ou testar um serviço específico
# - incluir suporte para definir os nomes dos servios através de um arquivo de configuração e/ou parâmetro na linha de comando
# 
# Autor: Eduardo Dias <eduardodiasbr@gmail.com>
#

function build_image() {
  cd $PWD/..
  BUILD_PATH=$PWD
  for image in mysql nodejs nginx
  do
    cd $BUILD_PATH/docker/$image
    exists=`docker images passeidireto/$image:latest | grep -v REPOSITORY`
    if [ "$exists" == "" ]
    then
      echo "Criando image do serviço de $image..."
      docker build -t passeidireto/$image:latest .
    else
      echo "Imagem já existe, se necessitar recriar favor executar o script com a flag --delete"
      image=`docker images passeidireto/$image:latest`
      echo $image | awk '{print $1 "\t\t" $2 "\t" $3}'
      echo $image | awk '{print $7 "\t" $8 "\t" $9}'
      echo
    fi
  done
}

function delete_image() {
  for image in mysql nodejs nginx
  do
    exists=`docker images passeidireto/$image:latest | grep -v REPOSITORY`
    if [ "$exists" == "" ]
    then
      echo "Imagem do serviço $image não existe..."
      echo
    else
      echo "Removendo imagem do serviço de $image..."
      docker rmi passeidireto/$image:latest
    fi
  done
}

function delete_container() {
  for container in mysql nodejs nginx
  do
    exists=`docker ps -a | grep $container.server`
    if [ "$exists" == "" ]
    then
      echo "Container do serviço $container não existe..."
      echo
    else
      echo "Removendo container do serviço $container..."
      docker rm $container.server
    fi
  done
}

function run_services() {
  for service in mysql nodejs nginx
  do
    exists=`docker ps -a | grep $service.server`
    if [ "$exists" == "" ]
    then
      echo "O serviço $service não existe, criando o container $service.server"
      case $service in
          mysql)
              docker run -i -t -d --name mysql.server -p 3306:3306 passeidireto/mysql:latest
              continue
              ;;
          nodejs)
              docker run -i -t -d --name nodejs.server -e NODEJS_API_PORT=8080 --link mysql.server:mysql.server -p 8080:8080 passeidireto/nodejs:latest
              continue
              ;;
          nginx)
              docker run -i -t -d --name nginx.server -p 80:80 --link nodejs.server:nodejs.server passeidireto/nginx
              continue
              ;;
      esac
      echo
    else
      running=`docker ps -a | grep $service.server | grep Exit`
      if [ "$running" == "" ]
      then
        echo "O serviço $service já está ativo, se necessitar restartar favor executar o script com a flag --stop e depois --run"
        service=`docker ps | grep $service.server`
        echo -e "CONTAINER ID\tIMAGE"
        echo $service | awk '{print $1 "\t" $2}'
        echo
      else
        echo "O serviço existe mas está parado, iniciando o serviço"
        docker start $service.server
        echo
      fi
    fi
  done
}

function stop_services() {
  for service in mysql nodejs nginx
  do
    exists=`docker ps -a | grep $service.server `
    if [ "$exists" == "" ]
    then
      echo "O serviço $service não existe, nenhuma ação a fazer..."
      echo
    else
      running=`docker ps -a | grep $service.server | grep Exit`
      if [ "$running" == "" ]
      then
        echo "O serviço $service está ativo, parando o serviço..."
        docker stop $service.server
        echo
      else
        echo "O serviço $service existe mas está parado, nenhuma ação a fazer..."
        echo
      fi
    fi
  done
}

function check_dir() {
  # echo $PWD
  # substring="exec"
  # echo $substring
  if [[ "$PWD"$ =~ "/exec" ]]; then
    echo "Iniciando o processo de `echo $ACTION | tr -d \"-\"` "
  else
    echo "Você não está no diretório correto, por favor vá para o diretório .../exec e execute o script novamente."
    exit
  fi
}

function usage() {
  echo "Use:"
  echo "manage_services.sh --help: mostra esse help"
  echo "manage_services.sh --build: gera as imagens dos serviços"
  echo "manage_services.sh --delete-image: remove as imagens e os containers dos serviços"
  echo "manage_services.sh --delete-container: remove as imagens e os containers dos serviços"
  echo "manage_services.sh --run: inicia os três serviços"
  echo "manage_services.sh --stop: para os três serviços"
  echo "manage_services.sh --test: para os três serviços"
  echo ""
}

function test_services(){
  echo "========================================"
  echo "Inserindo entrada no banco de dados"
  response=`curl -X POST --connect-timeout 2 -o /dev/null -s -w "%{http_code}\n" http://localhost/notes -d teste`
  if [ $response -ne 200 ]
  then
    echo "Erro na inserção de dados no banco, verifique se o serviço está ativo."
    echo "Response code: $response"
    echo "========================================"
  else
    echo "Inserção no banco foi feita com sucesso."
    echo "Response code: $response"
    echo "========================================"
  fi

  echo "Listando o conteúdo do banco de dados"
  response=`curl -X GET --connect-timeout 2 -o /dev/null -s -w "%{http_code}\n" http://localhost`
  if [ $response -ne 200 ]
  then
    echo "Erro no acesso ao banco de dados, verifique se o serviço está ativo."
    echo "Response code: $response"
    echo "========================================" 
  else
    echo "Acesso ao banco de dados foi feita com sucesso."
    echo "Response code: $response"
    response=`curl -X GET --silent http://localhost`
    echo -e "$response\t"
    echo "========================================"
  fi

  echo "Removendo entrada do banco de dados"
  id=`curl -X GET --silent --connect-timeout 2 http://localhost | grep Id | awk '{print $1}' | cut -f1 -d"," | cut -f2 -d":"`
  response=`curl -X DELETE --connect-timeout 2 -o /dev/null -s -w "%{http_code}\n" http://localhost/notes/$id`
  if [ $response -ne 200 ]
  then
    echo "Erro no acesso ao banco de dados, verifique se o serviço está ativo."
    echo "Response code: $response"
    echo "========================================"
  else
    if [ "$id" == "" ]
    then
      echo "O banco de dados está vazio..."
      echo "========================================"
    else
      echo "Acesso ao banco de dados foi feita com sucesso."
      echo "Id $id foi removido com sucesso."
      echo "Response code: $response"
      echo "========================================"
    fi
  fi

}

ACTION=$1

case $ACTION in
    --help)
        usage
        exit
        ;;
    --build)
        check_dir
        build_image
        exit
        ;;
    --delete-image)
        delete_image
        exit
        ;;
    --delete-container)
        delete_container
        exit
        ;;
    --run)
        run_services
        exit
        ;;
    --stop)
        stop_services
        exit
        ;;
    --test)
        test_services
        exit
        ;;
    *)
        echo "ERRO: parâmetro desconhecido ou nulo..."
        usage
        exit 1
        ;;
esac
