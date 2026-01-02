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

# Extrai a versão atual do Pasta local version.sh
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
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando Pastas
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
        index  ___i;        # realmente não precisamos de índice aqui, apenas listando Pastas.
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
    echo "${bold}${lightgreen}==> 🟢 Removendo Pastas Temporarios "
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



















#!/bin/sh
#        ====================================================
#                 Nginx Entrypoint Egg Criado por drysius
#        ====================================================
# Icones 🔴 🟠 🟡 🟢 🔵 🟣 🟤 ⚫ ⚪ ✅ ❌ 📍 ✂️ 🗑️ 🟧 🟨 ⬜ 
# Icones ☑️ ✖️ ❎ 💾 📓 📗 📘 📙 📝 📖 📚 📰 🗞️ 🏷️ 🟥 🟩 🟦 ⚙️ 
# Icones 📒 📔 📕 📑 📂 📁 🗂️ 🗃️ 🗄️ 📊 📈 📉 📇 📌 🟪 🟫 ⬛    
#

# Comandos Do painel Múdaveis
StartType="0" # Define que tipo de comando vai ser executado 0=Direto 1=Nohub.
Script_Type="2" # Define se este Script é Beta ou Alpha. 1=Alpha 2=Beta.
StartAMD="/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/" # Comando Start para amd.
StartARM="/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/" # Comando Start para arm.
Stop_CMD="Parar Servidor" # Comando para parar o Servidor.
Permissoes_padroes="chmod 777 ./*" # Define as permissões do Pastas, por padrão recomendo chmod 777 ./*.
Egg="Nginx               " # O Nome do egg que será executado, lembrando que o numero de caracteres maximos dentro "" é 20 oque não tiver de nome, use em espaços.
Pasta_Base="📂Informações" # O Nome da pasta onde vai ser armazenada todas as informações do Script.
Base_txt="🟢Informações.txt" # Nome do Pasta Onde vai Ficar os Verificadores do egg.
script_log="📔Script.log.txt" # Nome da Log que o Script vai Rodar.
debug_log="📔Debug.log.txt" # Nome da Log que vai rodar o Debug.
Base_Url="https://github.com/drysius/Eggs" #Link do github onde pode achar o egg.
version_file="./${Pasta_Base}/${Base_txt}" # Local onde a versão vai ser Armazenada.
version_remote="https://raw.githubusercontent.com/drysius/Eggs/main/Connect/NGINX/Vers%C3%A3o.txt" #Local onde a Versão Latest vai ser vista
# Cores do Terminal
C0=$(echo -en "\u001b[0m") # Padrão
C1=$(echo -en "\e[1m\u001b[36m") # Cor Ciano Com negrito.
C2=$(echo -en "\e[1m\u001b[32m") # Cor Verde Com Negrito.
C3=$(echo -en "\e[1m\u001b[31m") # Cor Vermelho Com Negrito.
C4=$(echo -en "\e[1m\u001b[34m") # Cor Azul Com Negrito.
C5=$(echo -en "\e[1m\u001b[35m") # Cor Margeta Com Negrito.
B0="\e[1m" # Negrito
# Dependencias do Script
# Criação da Pasta de Vefiricação
if [[ ! -f "./${Pasta_Base}/${Base_txt}" ]]; then mkdir -p ./${Pasta_Base}; echo -e "🟢Informações Do Script\n#\n🟢Criado por drysius\n🟢Github: https://github.com/drysius/Eggs\n🟢Versão Atual: PRÉ" > ./${Pasta_Base}/${Base_txt}; fi # Cria a pasta e o primeiro Pasta de versão.
if [[ ! -d "${Pasta_Base}/Logs" ]]; then mkdir -p ./${Pasta_Base}/Logs; fi
if [[ ! -d "./Arquivos" ]]; then mkdir -p ./Arquivos; fi
if [[ ! -d "./Arquivos/Secreto" ]]; then mkdir -p ./Arquivos/Secreto; fi
Arquitetura=$([ "$(uname -m)" == "x86_64" ] && echo "AMD64" || echo "ARM64") # Pega a Arquitetura da maquina
StartUP_CMD=${StartARM} [ "${Arquitetura}" == "ARM64" ] || StartUP_CMD=${StartAMD} # isto é o que de fato vai executar como StartUP_CMD
version=$(grep "🟢Versão Atual: " "$version_file" | cut -d' ' -f3) # Lendo a versão local
if [ "${version}" == "PRÉ" ]; then version2="${version}"; else version2="${version} "; fi #organiza o tamanho da versão
if [ "${SUPORTE_ATIVO}" == "1" ]; then Suporte_egg="✅ ${C1}Definido  ${C0}"; else Suporte_egg="❌ ${C3}Indefinido${C0}"; fi # Verificação do Suporte
if [ "${AUTO_UPDATE}" == "1" ]; then Updater_egg="✅ ${C1}Definido  ${C0}"; else Updater_egg="❌ ${C3}Indefinido${C0}"; fi # Verificação do Atualização.
if [ "${StartType}" == "0" ]; then Type_egg="✅ ${C1}Direto    ${C0}"; else Type_egg="✅ ${C1}NoHub     ${C0}"; fi # Verificação do TypeStart
if [ "${Script_Type}" == "1" ]; then Scriptstat="${C1}Alpha${C0}"; else Scriptstat="${C1}Beta ${C0}"; fi # Beta sim e não
if [ -z "${SUPORTE_ATIVO}" ]; then Suporte="❌ ${C3}Desativado${C0}"; else Suporte="✅ ${C1}Ativado   ${C0}"; fi # Verificação do Suporte egg
if [ -z "${AUTO_UPDATE}" ]; then Updater="❌ ${C3}Desativado${C0}"; else  Updater="✅ ${C1}Ativado   ${C0}"; fi # Verificação do Atualização egg
# Carregar Versões
version_latest=$(curl -s "$version_remote" | grep "🟢Versão Latest: " | cut -d' ' -f3) # Lendo a versão remota
if [ "$version" != "$version_latest" ]; then version_update="> ${C2}${version_latest}${C0}"; else version_update="    "; fi # Verificando se há uma nova versão disponível.
# Inicio Do Script
if [ -z ${SUPORTE_ATIVO} ] || [ "${SUPORTE_ATIVO}" == "1" ]; then
    echo "
    .+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-*.
    |                                          |                  ${C5}INICIANDO SCRIPT${C0}                   |
    |                   ${C5}:%*${C0}                    |+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+-|
    |                  ${C4}:%@@*${C0}                   |                          |                          |
    |                 ${C5}-@@@@@#${C0}                  | ${C0}Egg:${C1} ${Egg}${C0}| Arquitetura:${C1} ${Arquitetura} ${C0}      |
    |                ${C4}=@@@@@@@%.${C0}                | Versão: ${C1}${version2}${C0} ${version_update}        | Script: ${C1}${Scriptstat}${C0}            |
    |               ${C5}+@@@@#%@@@%:${C0}               | StartType: ${Type_egg} |                          |
    |              ${C4}+@@@@= .#@@@%:${C0}              |                          |                          |
    |             ${C5}*@@@@-    #@@@@-${C0}             |+*-+*-+*-+*-+*-+*-+*-+*-+*|+*-+*-+*-+*-+*-+*-+*-+*-+*|
    |            ${C4}#@@@@:      *@@@@=${C0}            |     ${C5}VARIANTES DO EGG${C0}     |   ${C5}ATIVADOS/DESATIVADOS${C0}   |
    |          ${C5}.%@@@%:        +@@@@+${C0}           |+*-+*-+*-+*-+*-+*-+*-+*-+*|+*-+*-+*-+*-+*-+*-+*-+*-+*|
    |         ${C4}:%@@@%.          =@@@@*${C0}          |                          |                          |
    |        ${C5}:%@@@#   ++++++++++@@@@@*${C0}         | Suporte: ${Suporte_egg}   | Suporte: ${Suporte}   |
    |       ${C4}=@@@@#  .%@@@@@@@@@@@@@@@@%.${C0}       |                          |                          |
    |      ${C5}-%%%%#. .+%##########%%%%%#%*.${C0}      | Update: ${Updater_egg}    | Update: ${Updater}    |
    |    ${C4} -------  ------------------------${C0}    |                          |                          |
    |                                          |                          |                          |
    *-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*°-+*-+*-+*+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+.*
    "  
    if [ -z "$AUTO_UPDATE" ] || [ -z "$SUPORTE_ATIVO" ]; then
    echo "
    ${C3}.-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*+-+*-+*-+*+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+-.
    ${C3}|   UMA OU MAIS VARIANTES DO EGG ESTÃO EM FALTA, BAIXE A VERSÃO MAIS RECENTE DO EGG NO GITHUB.   |
    ${C3}|                                 https://github.com/drysius/Eggs                                |
    ${C3}*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*+-+*-+*-+*+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+*-+.* 
    ${C0}"
    fi
        # Atualizações
    if [ "${AUTO_UPDATE}" == "1" ]; then
        echo " 🔵 A ${C1}Atualizações Automatica${C0} está ${C2}Ativada${C0}, Buscando Atualizações..."
        if [ "$version" == "PRÉ" ]; then
            echo " 🔵   ${C1}Versão Inicial${C0} detectada, Iniciando Downloads"
            sed -i '/🟢Versão Atual:*/d' ./${Pasta_Base}/${Base_txt}
            echo  "🟢Versão Atual: ${version_latest}" >> "./${Pasta_Base}/${Base_txt}"
        elif [ "$version" != "$version_latest" ]; then
            echo " 🔵   Nova ${C1}Versão${C0} detectada, Iniciando Atualização."
            # Oque vai Fazer se tiver atualização
            
            # Seta a versão mais atual
            sed -i '/🟢Versão Atual:*/d' ./${Pasta_Base}/${Base_txt}
            echo  "🟢Versão Atual: ${version_latest}" >> "./${Pasta_Base}/${Base_txt}"
            echo ""
            echo " 🔵   Sistema foi ${C1}Atualizado${C0} versão atual ${version}..."
        elif [ "$version" == "$version_latest" ]; then
            echo " 🔵   Sistema está ${C1}Atualizado${C0} versão atual ${version}..."
        fi
    else
        echo " 🟡   A ${C1}Atualizações Automatica${C0} está ${C3}Desativada${C0}, Pulando etapa..."
    fi
    echo " 🔵   Iniciando Script de ${C1}Verificação e Instalação${C0} das dependecias..."
    # Aqui ficará o Script
    # NGINX Verificador
    if grep -q "🟢NGINX instalado" "./📂Informações/🟢Informações.txt"; then
        echo " 🔵   O ${C1}Nginx${C0} foi detectado como Instalado, Verificando Pasta..."
        if [[ -f "./announce" ]]; then
            echo " 🔵   A Pasta ${C1}Nginx${C0} foi verificado, Continuando iniciação..."
        else
            echo " 🟡   A Pasta ${C1}Nginx${C0} ${C3}não${C0} foi encontrada, Baixando..."
            curl -s -L -o /home/container/announce "https://github.com/drysius/Eggs/releases/latest/download/announce"
            echo " 🔵   A Pasta ${C1}Nginx${C0} foi ${C2}baixada${C0}, Continuando iniciação..."
        fi
    else
        echo " 🔵   O ${C1}Nginx${C0} ${C3}não${C0} foi detectado como Instalado, Verificando Pasta..."
        if [[ -f "./announce" ]]; then
            echo " 🟡   A Pasta ${C1}Nginx${C0} foi encontrada, porém não está nas normas do script, Deletando..."
            rm -f ./announce
            echo " 🟢   Baixando a Pasta ${C1}NGINX${C0} verificado..."
            curl -s -L -o /home/container/announce "https://github.com/drysius/Eggs/releases/latest/download/announce"
            echo " 🔵   A Pasta ${C1}Nginx${C0} foi ${C2}baixado${C0}, Continuando iniciação..."
            echo "🟢NGINX instalado" >> "./📂Informações/🟢Informações.txt"
        else
            echo " 🟡   A Pasta ${C1}Nginx${C0} ${C3}não${C0} foi encontrada, Baixando..."
            curl -s -L -o /home/container/announce "https://github.com/drysius/Eggs/releases/latest/download/announce"
            echo " 🔵   A Pasta ${C1}Nginx${C0} foi ${C2}baixado${C0}, Continuando iniciação..."
            echo "🟢NGINX instalado" >> "./📂Informações/🟢Informações.txt"
        fi
    fi























    echo ""
    echo " 🔵   Setando ${C1}Permissões${C0} padrões."
    eval "$Permissoes_padroes"
    # Fim do Script
    echo " 🔵   ${C1}Verificação e Instalação${C0} dependecias foi terminado, Iniciando Inicializador..."
    # O StartType do comando não necessita mudar
    if [ "${StartType}" == "1" ]; then
        nohup ${StartUP_CMD} > ${Egg}.log.txt 2> ${Egg}.erro.log.txt &
        pid=$!
        # Continua a exibir as últimas linhas do Pasta de log a cada segundo
        while true; do
            tail -n 10 -F ${Egg}.log.txt
            tail -n 10 -F ${Egg}.erro.log.txt
            sleep 1
            # Verifica se o processo do aplicativo ainda está ativo
            if ! kill -0 $pid 2> /dev/null; then
                # Salva as logs na pasta "./${Pasta_Base}/Logs/"./Informacoes/Informacoes.txt
                echo "🔴   ${C3}O ${Egg} foi finalizado sem aviso, provavelmente erro interno, desligando script${C0}..."
                if [ ! -f "./${Pasta_Base}/Logs/${Egg}.log.txt" ]; then
                  	echo " " > "./${Pasta_Base}/Logs/${Egg}log.txt"
                fi
                
                if [ ! -f "./${Pasta_Base}/Logs/${Egg}.log.txt" ]; then
                  	echo " " > "./${Pasta_Base}/Logs/${Egg}.log.txt"
                fi

                cat ${Egg}.log.txt >> ./${Pasta_Base}/Logs/${Egg}.log.txt
                cat ${Egg}.erro.log.txt >> ./${Pasta_Base}/Logs/${Egg}.erro.log.txt

                rm ${Egg}.log.txt
                rm ${Egg}.erro.log.txt
                break
            fi
        done &
        tail_pid=$!
    else
        eval ${StartUP_CMD}
    fi
    # Aguarda input do usuário
        while read line; do
            if [ "$line" = "${Stop_CMD}" ]; then
                kill $pid
                echo "🟢   ${C1}Comando de Desligamento${C0} Executado, Salvando Pastas..."
                if [ ! -f "./${Pasta_Base}/Logs/${Egg}.log.txt" ]; then
                  	echo " " > "./${Pasta_Base}/Logs/${Egg}log.txt"
                fi

                if [ ! -f "./${Pasta_Base}/Logs/${Egg}.log.txt" ]; then
                  	echo " " > "./${Pasta_Base}/Logs/${Egg}.log.txt"
                fi

                cat ${Egg}.log.txt >> ./${Pasta_Base}/Logs/${Egg}.log.txt
                cat ${Egg}.erro.log.txt >> ./${Pasta_Base}/Logs/${Egg}.erro.log.txt

                rm ${Egg}.log.txt
                rm ${Egg}.erro.log.txt
                sleep 5
                break
            if [ "$line" = "criar usuario" ]; then
              echo "1- Digite o nome do usuário:"
              read username
              echo "2- Digite a senha do usuário:"
              read password
              echo "3- Digite em barras a pasta onde o usuário será usado (exemplo = /Arquivos/UmPastaSecreta):"
              read folder

              # criando o Pasta .htpasswd
              echo "${username}:$(openssl passwd -apr1 $password)" > "$folder/.htpasswd"
              echo "${bold}${lightgreen}== 🟢 Usuário criado com sucesso!"

              # configurando o Nginx
              conf_file="/etc/nginx/conf.d/$folder.conf"
              echo "location $folder {" > "$conf_file"
              echo "  auth_basic \"Restricted Content\";" >> "$conf_file"
              echo "  auth_basic_user_file $folder/.htpasswd;" >> "$conf_file"
              echo "}" >> "$conf_file"
              echo "${bold}${lightgreen}== 🟢 Configuração do Nginx atualizada com sucesso!"

              elif [ "$line" = "deletar usuario" ]; then
                  echo "Digite o nome do usuário que você deseja excluir:"
                  read username
                  echo "Digite a pasta em que o usuário foi criado:"
                  read folder
                  # verificando se o Pasta .htpasswd existe
                  htpasswd_file="$folder/.htpasswd"
                  if [ -f "$htpasswd_file" ]; then
                      # removendo a linha correspondente ao usuário do Pasta .htpasswd
                      sed -i "/^${username}:/d" "$htpasswd_file"
                      echo "${bold}${lightgreen}== 🟢 Usuário excluído com sucesso!"
                  else
                      echo "${bold}${lightgreen}== 🟢 O Pasta .htpasswd para esta pasta não existe ou está vazio!"
                  fi
            else
                echo "🔴   Script ${C3}Falhou${C0} ou Forçado pelo ${C3}Kill${C0}."
            fi
        done
    kill $tail_pid
fi # If final