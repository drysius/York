#!/bin/sh
# parece sacanagem mais aqui dentro tem um espaço que deve ser usado caso queira colocar versão " " o texto todo "versão: "
# icones 🔴 🟠 🟡 🟢 🔵 🟣 🟤 ⚫ ⚪ ✅ ❌ 
# Versão do Entrypoint
entrypoint_vurl="https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/Versao_Atual"
entrypoint_version=$(curl -s "$entrypoint_vurl" | grep "Entrypoint: " | awk '{print $2}')
# Aguarde até que o contêiner seja totalmente inicializado
sleep 1
#Verifica a Arquitetura do Docker
Arquitetura=$([ "$(uname -m)" == "x86_64" ] && echo "amd64" || echo "arm64")
# Verifica se a conexão vai ser local ou externa
if [ "${MODE_CONEXAO}" == "1" ]; then
Online_Mode=""
Online_Mode2=""
Online_Mode3=""
Online_Mode4=""
else
Online_Mode="deny all;"
Online_Mode2="allow 127.0.0.1;"
Online_Mode3="allow 192.168.0.0/24;"
Online_Mode4="allow 172.17.0.0/16;"
fi
# URL para a versão mais recente
latest_version_url="https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/Versao_Atual"

# Extrai a versão atual do arquivo local version.sh
current_version=$(grep "Instalação: " ./Status/Versao_Atual | awk '{print $2}')

# Extrai a versão mais recente da URL
latest_version=$(curl -s "$latest_version_url" | grep "Instalação: " | awk '{print $2}')

# Cores do Sistema
bold=$(echo -en "\e[1m")
lightgreen=$(echo -en "\e[92m")
vermelho=$(echo -en "\e[31m")
# ${bold}${vermelho}

if [ -z ${SUPORTE_ATIVO} ] || [ "${SUPORTE_ATIVO}" == "1" ]; then
  echo "${bold}${lightgreen}=============================================================================="
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}==>                     - - - Script  Entrypoint - - -                     <=="
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}=============================================================================="
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}==>                  - - - Informações da Maquina. - - -                   <=="
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Vefirica Arquitetura da Maquina
  if [ "${Arquitetura}" == "arm64" ]; then 
      echo "${bold}${lightgreen}==> 🔵 Arquitetura :Alpine Arm64x                                           <=="
    else
      echo "${bold}${lightgreen}==> 🔵 Arquitetura :Alpine AMD64x                                           <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}==> ✅ Versão do Entrypoint: $entrypoint_version                                            <=="
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Versão da Instalação
  if [ -z "$current_version" ]; then
  echo "${bold}${lightgreen}==> ⚫ Versão da instalação: Pre-instalação, não disponivel ou customizada. <=="
  else
  echo "${bold}${lightgreen}==> ✅ Versão da Instalação Atual: $current_version                                      <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Se Atualização Automatica está ativada
  if [ "${AUTO_UPDATE}" == "1" ]; then
  echo "${bold}${lightgreen}==> ✅ Sistema de Atualização Automatica está ativado.                      <=="
  else
  echo "${bold}${lightgreen}==> ❌ Sistema de Atualização Automatica está ${bold}${vermelho}desativado${bold}${lightgreen}.                   <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Se Reparação Automatica está ativada
  if [ "${REPARAR_SISTEMA}" == "1" ]; then
  echo "${bold}${lightgreen}==> ✅ Sistema de Reparação Automatica está ativada.                        <=="
  else
  echo "${bold}${lightgreen}==> ❌ Sistema de Reparação Automatica está ${bold}${vermelho}desativado${bold}${lightgreen}.                     <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Se HTML esta local ou na nuvem
  if [ "${HTML_LOCAL}" == "1" ]; then
  echo "${bold}${lightgreen}==> ✅ Sistema de HTML está na nuvem(Padrão).                               <=="
  else
  echo "${bold}${lightgreen}==> ❌ Sistema de HTML está no local (Não Recomendado). ${bold}${vermelho}desativado${bold}${lightgreen}.         <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Se O MODE_CONEXAO é local ou é externo
  if [ "${MODE_CONEXAO}" == "1" ]; then
  echo "${bold}${lightgreen}==> 🟡 Conexão Externa Ativada(Permite qualquer um Ver e baixar no Site).   <=="
  else
  echo "${bold}${lightgreen}==> 🟢 Conexão Interna Ativada(Apenas a maquina pode baixar e ver o site).  <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica Se O MODE_CONEXAO é local ou é externo
  if [ "${DEFAULT_CONF}" == "1" ]; then
  echo "${bold}${lightgreen}==> ✅ Default.conf Automatica está ativada.                                <=="
  else
  echo "${bold}${lightgreen}==> ❌ Default.conf Automatica está ${bold}${vermelho}desativada${bold}${lightgreen}.                             <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}=============================================================================="
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}==>                           Verificação do Egg                           <=="
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica se o Suporte_Ativo existe no egg
  if [ -z "$SUPORTE_ATIVO" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante do Suporte(ativar/desativar) do egg não está definida.      <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante do Suporte(ativar/desativar) do egg está definida.          <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  # Verifica se o AUTO_UPDATE existe no egg
  if [ -z "$AUTO_UPDATE" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante do Atualização(ativar/desativar) do egg não está definida.  <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante do Atualização(ativar/desativar) do egg está definida.      <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
   # Verifica se o REPARAR_SISTEMA existe no egg
  if [ -z "${REPARAR_SISTEMA}" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante do Reparação(ativar/desativar) do egg não está definida.    <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante do Reparação(ativar/desativar) do egg está definida.        <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
   # Verifica se o HTML_LOCAL existe no egg
  if [ -z "${HTML_LOCAL}" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante do HTML(ativar/desativar) do egg não está definida.         <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante do HTML(ativar/desativar) do egg está definida.             <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
   # Verifica se o MODE_CONEXAO existe no egg
  if [ -z "${MODE_CONEXAO}" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante da Conexão(ativar/desativar) do egg não está definida.      <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante da Conexão(ativar/desativar) do egg está definida.          <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
   # Verifica se o MODE_CONEXAO existe no egg
  if [ -z "${DEFAULT_CONF}" ]; then
  echo "${bold}${lightgreen}==> ❌ Variante da Default.conf(ativar/desativar) do egg não está definida. <=="
  else
  echo "${bold}${lightgreen}==> ✅ Variante da Default.conf(ativar/desativar) do egg está definida.     <=="
  fi
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}=============================================================================="
  # Avisa caso exista variantes não definidas
  if [ -z "$AUTO_UPDATE" ] || [ -z "$SUPORTE_ATIVO" ] || [ -z "${REPARAR_SISTEMA}" ] || [ -z "${HTML_LOCAL}" ] || [ -z "${MODE_CONEXAO}" ] || [ -z "${DEFAULT_CONF}" ]; then
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}==>   ${bold}${vermelho}Uma ou mais Variantes estão indefinidas neste egg, recomendado que${bold}${lightgreen}   <=="
  echo "${bold}${lightgreen}==>             ${bold}${vermelho}o atualize para versão mais recente do github.${bold}${lightgreen}             <=="
  echo "${bold}${lightgreen}==>            ${bold}${vermelho} https://github.com/drysius/Eggs/tree/main/Eggs ${bold}${lightgreen}            <=="
  echo "${bold}${lightgreen}==>                                                                        <=="
  echo "${bold}${lightgreen}=============================================================================="
  echo " "
  fi
  # Sistema de Erro------------------------------------------------
    if [[ -f "./Status/Formatar_Sistema" ]]; then
    echo "${bold}${lightgreen}==> 🔴 Detectado Erro no Entrypoint."
    echo "${bold}${lightgreen}==> 🔴 Iniciando Script de Limpeza."
    rm -rf ./nginx
    rm -rf ./Status
    rm -rf ./Explorer
    rm -rf ./tmp
    rm -rf ./Cache
    rm -rf ./logs
    rm ./index.html
    echo "${bold}${lightgreen}==> 🔴 Terminado, Iniciando Scripts padrões."
    else
    echo " "
    fi
  # Fim Sistema de Erro--------------------------------------------

  # Atualizações---------------------------------------------------
    echo "${bold}${lightgreen}==> 🟢 Iniciando Script."

    if [ "${AUTO_UPDATE}" == "1" ]; then
    echo "${bold}${lightgreen}==> 🟠 Iniciando Verificação de Atualizações."
      if [ -z "$current_version" ] || [ "$current_version" != "$latest_version" ]; then
      echo "${bold}${lightgreen}==> 🟠 Buscando Atualizações."
      echo "${bold}${lightgreen}==> 🟠 Nova versão encontrada: $latest_version, preparando para atualização."
      rm -rf ./nginx
      rm -rf ./Status
      rm -rf ./Explorer
      rm -rf ./tmp
      rm -rf ./Cache
      rm -rf ./logs
      rm ./index.html
      echo "${bold}${lightgreen}==> 🟠 iniciando script de instalação da nova versão:$latest_version."
      else
      echo "${bold}${lightgreen}==> 🟢 Verificação de Atualizações Detectou que a Sua versão é a mais atual."
      fi
    else
    echo "${bold}${lightgreen}==> 🔴 Verificação de Atualizações Desativado, Pulando etapa."
    fi
  # Fim Atualizações-----------------------------------------------
   
  # Sistema do Nginx-----------------------------------------------
   if [[ -f "./Status/Nginx_instalador" ]]; then
      echo "${bold}${lightgreen}==> 🟢 Nginx foi detectado, pulando Download."
   else
      echo "${bold}${lightgreen}==> 🔴 Verificador do Nginx ${bold}${vermelho}não foi detectado ${bold}${lightgreen}, Iniciando download."
      mkdir ./Cache
      git clone -q https://github.com/finnie2006/ptero-nginx ./Cache
      mkdir ./nginx
      cp -r ./Cache/nginx/* ./nginx
      rm -rf ./Cache
      mkdir ./Status
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/Leiame.txt  -o ./Status/Leia-me.txt
      touch ./Status/Nginx_instalador
    fi
  # Fim do Nginx---------------------------------------------------

  # Sistema do Nginx Explorador------------------------------------
   if [[ -f "./Status/Explorer_instalador" ]]; then
      echo "${bold}${lightgreen}==> 🟢 Nginx Explorer foi detectado, pulando Download."
   else
      echo "${bold}${lightgreen}==> 🔴 Verificador do Nginx Explorer ${bold}${vermelho}não foi detectado ${bold}${lightgreen}, Iniciando download."
      mkdir ./Explorer
      
      git clone -q https://github.com/drysius/nginx-explorer ./Explorer
      touch ./Status/Explorer_instalador
    fi
  # Fim do Nginx Explorador----------------------------------------

  # Sistema das Logs-----------------------------------------------
   if [[ -f "./Status/Pasta_instalador" ]]; then
      echo "${bold}${lightgreen}==> 🟢 Verificador da Logs foi detectado, Executando procedimento padrão da pasta Logs."
      mkdir ./Cache
      mv ./logs/* ./Cache
      rm -r ./logs
      mkdir ./logs >/dev/null
      mv ./Cache/* ./logs
      rm -r ./Cache
   else
      echo "${bold}${lightgreen}==> 🔴 Verificador da Pasta Logs ${bold}${vermelho}não foi detectado ${bold}${lightgreen}, Criando."
      mkdir ./logs >/dev/null
      touch ./Status/Pasta_instalador
    fi
  # Fim das Logs---------------------------------------------------

# Sistema do default.conf----------------------------------------
if [[ -f "./Status/Default.conf_instalado" ]]; then
echo "${bold}${lightgreen}==> 🟢 Default.conf ja carregado, executando Padrões no Break."
if [ -z "${DEFAULT_CONF}" ] || [ "${DEFAULT_CONF}" == "1" ]; then
rm ./nginx/conf.d/default.conf
cat > ./nginx/conf.d/default.conf << EOL
server {
    listen ${SERVER_PORT};
    server_name "";

    root   /home/container/;
    index  index.html index.htm;

    location / {
        ${Online_Mode} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode2} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode3} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode4} # Verifica se a conexão vai ser local ou externa


    location /Arquivos/ {
        alias /home/container/Arquivos/;
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando arquivos
        autoindex on;
        autoindex_format json;
        disable_symlinks off;

    location /Arquivos/Publica {
        allow all;

      }
    }
  }
}

EOL
  else
  echo "${bold}${lightgreen}==> 🟠 Default.conf Personalizado, pulando no break."
  fi
    else
      echo "${bold}${lightgreen}==> 🔴 Verificador do Default.conf ${bold}${vermelho}não foi detectado ${bold}${lightgreen}, Iniciando download."
      mkdir ./Arquivos
      mkdir ./Arquivos/Publica
      rm ./nginx/conf.d/default.conf
cat > ./nginx/conf.d/default.conf << EOL
server {
    listen ${SERVER_PORT};
    server_name ""; # ${Online_Mode} antiga variante

    root   /home/container/;
    index  index.html index.htm;

    location / {
        ${Online_Mode} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode2} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode3} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode4} # Verifica se a conexão vai ser local ou externa

    location /Arquivos/ {
        alias /home/container/Arquivos/;
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando arquivos.
        autoindex on;
        autoindex_format json;
        disable_symlinks off; 

    location /Arquivos/Publica {
        allow all;

      }
    }
  }
}
EOL
      echo "${bold}${lightgreen}==> 🟠 Criando Introdução."
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/introducao.md -o ./Arquivos/introducao.md
      touch ./Status/Default.conf_instalado
    fi
# Fim do default.conf--------------------------------------------

  # Setando Versão-------------------------------------------------
    if [[ -f "./Status/Versao_Atual" ]]; then
      echo "${bold}${lightgreen}==> 🟢 Versão Atual:$current_version."
    else
      echo "${bold}${lightgreen}==> 🟢 Setando Versão Recente:$latest_version."
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/Versao_Atual -o ./Status/Versao_Atual
    fi
  # Fim Setando Versão--------------------------------------------

  echo "${bold}${lightgreen}==> 🟢 Verificação Completa."

  # Iniciando HTML------------------------------------------------
    if [ "${HTML_LOCAL}" == "1" ]; then
    echo "${bold}${lightgreen}==> 🟢 Iniciando HTML"
    if [[ -f "./index.html" ]]; then
    echo "${bold}${lightgreen}==> 🟢 Iniciando HTML Na Nuvem"
      rm ./index.html
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/index.html -o ./index.html
    else
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/index.html -o ./index.html
    fi
    else
    if [[ -f "./index.html" ]]; then
      echo "${bold}${lightgreen}==> 🟠 Iniciando HTML Local"
    else
      echo "${bold}${lightgreen}==> 🟠 HTML Local não detectado, baixando."
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/index.html -o ./index.html
    fi
    fi
  # Fim HTML------------------------------------------------------

  # Permissões-----------------------------------------------------
    echo "${bold}${lightgreen}==> 🟢 Setando permissões padrões."
    chmod 777 ./*
  # Fim Permissões-------------------------------------------------

  # Limpar Tmp-----------------------------------------------------
    echo "${bold}${lightgreen}==> 🟢 Removendo Arquivos Temporarios "
    rm -rf /home/container/tmp/*
  # Fim Limpar Tmp-------------------------------------------------

  # Dialogo--------------------------------------------------------
    echo "${bold}${lightgreen}==> 🟢 Iniciado Nginx "
    echo "${bold}${lightgreen}==> 🟢 Inicializado com sucesso"
    echo "${bold}${lightgreen}==> 🟢 Finalizando iniciador online"
    echo " "
    echo "${bold}${lightgreen}=============================================================================="
    echo "${bold}${lightgreen}==> 🟢 Final do Entrypoint: $entrypoint_version                                             <=="
    echo "${bold}${lightgreen}=============================================================================="
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
  # Fim Dialogo----------------------------------------------------

  # Comando Nginx start--------------------------------------------
  nohup /usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/ > log_nginx.txt 2>&1 &
  pid=$!

  # Continua a exibir as últimas linhas do arquivo de log a cada segundo
  while true; do
  tail -n 10 -F log_nginx.txt
  sleep 1
  done &
  tail_pid=$!

  # Aguarda input do usuário
  while read line; do
  if [ "$line" = "Sistema Entrypoint.sh Parar" ]; then
    kill $pid
    echo "${bold}${lightgreen}=============================================================================="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}== 🟢 Comando de Desligamento executado.                                     =="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}=============================================================================="
    cat ./log_nginx.txt >> ./Arquivos/log_nginx.txt
    break
    elif [ "$line" != "Sistema Entrypoint.sh Parar" ]; then
    echo "${bold}${lightgreen}=============================================================================="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}== 🔴 Comando Invalido, oque vocẽ está tentando fazer?                       =="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}=============================================================================="
    else
  # Dialogo de Erro------------------------------------------------
    echo " "
    if [ "${REPARAR_SISTEMA}" == "1" ]; then
    echo "${bold}${lightgreen}=============================================================================="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}==  ${bold}${vermelho} O Entrypoint Foi Finalizado Com Erro, Sistema de Restauração ativado ${bold}${lightgreen}  =="
    echo "${bold}${lightgreen}==            ${bold}${vermelho} Caso não funcione, entre em contato com drysius. ${bold}${lightgreen}            =="
    echo "${bold}${lightgreen}==                      ${bold}${vermelho} https://github.com/drysius/ ${bold}${lightgreen}                       =="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}=============================================================================="
    touch ./Status/Formatar_Sistema
    else
    echo "${bold}${lightgreen}=============================================================================="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}== ${bold}${vermelho}O Entrypoint Foi Finalizado Com Erro, Sistema de Restauração desativado${bold}${lightgreen}  =="
    echo "${bold}${lightgreen}==                           ${bold}${vermelho} - Sem Suporte -  ${bold}${lightgreen}                             =="
    echo "${bold}${lightgreen}==                                                                          =="
    echo "${bold}${lightgreen}=============================================================================="
    fi
  # Fim Dialogo de Erro--------------------------------------------
  fi
  done
  # Interrompe a exibição das logs
  kill $tail_pid
  # Fim Nginx start------------------------------------------------
  
else
  # Dialogo--------------------------------------------------------
    echo "${bold}${vermelho}================================================================================"
    echo "${bold}${vermelho}= O Script de Iniciação está Desativado, iniciando sem script(Não recomendado) ="
    echo "${bold}${vermelho}= O Sistema apenas irá carregar(se for necessario) o Default.conf e a Conexão. ="
    echo "${bold}${vermelho}================================================================================"
  # Fim Dialogo----

# Sistema do default.conf----------------------------------------
if [[ -f "./Status/Default.conf_instalado" ]]; then
echo "${bold}${lightgreen}==> 🟢 Default.conf ja carregado, executando Padrões no Break."
if [ -z "${DEFAULT_CONF}" ] || [ "${DEFAULT_CONF}" == "1" ]; then
rm ./nginx/conf.d/default.conf
cat > ./nginx/conf.d/default.conf << EOL
server {
    listen ${SERVER_PORT};
    server_name "";

    root   /home/container/;
    index  index.html index.htm;

    location / {
        ${Online_Mode} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode2} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode3} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode4} # Verifica se a conexão vai ser local ou externa


    location /Arquivos/ {
        alias /home/container/Arquivos/;
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando arquivos
        autoindex on;
        autoindex_format json;
        disable_symlinks off;

    location /Arquivos/Publica {
        allow all;

      }
    }
  }
}

EOL
  else
  echo "${bold}${lightgreen}==> 🟠 Default.conf Personalizado, pulando no break."
  fi
    else
      echo "${bold}${lightgreen}==> 🔴 Verificador do Default.conf ${bold}${vermelho}não foi detectado ${bold}${lightgreen}, Iniciando download."
      mkdir ./Arquivos
      mkdir ./Arquivos/Publica
      rm ./nginx/conf.d/default.conf
cat > ./nginx/conf.d/default.conf << EOL
server {
    listen ${SERVER_PORT};
    server_name ""; # ${Online_Mode} antiga variante

    root   /home/container/;
    index  index.html index.htm;

    location / {
        ${Online_Mode} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode2} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode3} # Verifica se a conexão vai ser local ou externa
        ${Online_Mode4} # Verifica se a conexão vai ser local ou externa

    location /Arquivos/ {
        alias /home/container/Arquivos/;
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando arquivos.
        autoindex on;
        autoindex_format json;
        disable_symlinks off; 

    location /Arquivos/Publica {
        allow all;

      }
    }
  }
}
EOL
      echo "${bold}${lightgreen}==> 🟠 Criando Introdução."
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/introducao.md -o ./Arquivos/introducao.md
      touch ./Status/Default.conf_instalado
    fi
# Fim do default.conf--------------------------------------------

if [[ -f "./index.html" ]]; then
    echo "${bold}${lightgreen}==> 🟢 Iniciando HTML Local"
    else
    echo "${bold}${lightgreen}==> 🟢 HTML Local não encontrado, Baixando"
      curl -s https://raw.githubusercontent.com/drysius/Eggs/main/Connect/Nginx/index.html -o ./index.html
  fi
  cd /home/container

  # Substituir variáveis ​​de inicialização
  MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
  echo ":/home/container$ ${MODIFIED_STARTUP}"

  # Execute o servidor
  ${MODIFIED_STARTUP}
fi
rm ./log_nginx.txt
echo " "
echo "${bold}${lightgreen}=============================================================================="
echo "${bold}${lightgreen}==                                                                          =="
echo "${bold}${lightgreen}== 🟢 Sistema Desligado, Até Mais.                                           =="
echo "${bold}${lightgreen}==                                                                          =="
echo "${bold}${lightgreen}=============================================================================="
