# debian-nvidia-installer

Instalador de drivers NVIDIA com TUI em Bash
A ferramenta permite instalar drivers NVIDIA no Debian usando uma interface
interativa em modo texto (TUI). Automatiza etapas como instalação de pacotes,
verificação de compatibilidade e configuração do ambiente gráfico.

<img src="data/screenshots/main-menu.png">

<div style="display:flex; gap:10px;">
  <img src="data/screenshots/drivers-menu.png" width="270" height="183">
  <img src="data/screenshots/post-installation-menu.png" width="270" height="183">
  <img src="data/screenshots/app-gpu-preferences-menu.png" width="270" height="183">
</div>

### Requisitos

* Distribuição Debian Trixie
* Arquitetura amd64
* Placa gráfica NVIDIA compatível
  > Os drivers oficiais da NVIDIA no Debian Trixie não oferecem suporte a [GPUs com arquitetura Fermi ou Kepler](https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/).

  > Consulte o [guia do Debian sobre a instalação de drivers legados](https://wiki.debian.org/NvidiaGraphicsDrivers#Tesla_Drivers) se necessário.
* Shell compatível com Bash
* Privilégios de administrador (sudo/root)

# Como executar

Após a instalação, você pode iniciar o script através do atalho na lista de aplicativos ou através do terminal executando o comando:

```bash
sudo debian-nvidia-installer
```

> ⚠️ **É necessário executar como root**, pois a ferramenta realiza alterações no sistema, como instalação de pacotes e modificação de arquivos de configuração.

# Instalação

Você pode instalar o `debian-nvidia-installer` baixando o pacote `.deb` a partir da seção **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** deste repositório.

### Opção 1: Interface gráfica

1. Baixe o arquivo `.deb` do script.
2. Dê **dois cliques** sobre o arquivo para abri-lo no gerenciador de pacotes do sistema.
3. Clique em **“Instalar”**. Você pode ser solicitado a digitar a senha de administrador.

> 💡 Compatível com gerenciadores como GDebi, Discover (KDE), GNOME Software, e outros similares.

### Opção 2: Terminal

Antes de começar, verifique a versão do pacote .deb que você baixou do GitHub. Substitua `X.X.X` nos comandos a seguir pela versão correta.
Exemplo: se a versão for `0.0.1`, o arquivo será `debian-nvidia-installer_0.0.1_amd64.deb`.

Copie o arquivo `.deb` para o diretório `/tmp`, para evitar problemas de permissão com o gerenciador de pacotes do sistema:

```bash
cp ./debian-nvidia-installer_X.X.X_amd64.deb /tmp/
```

> 💡 Arquivos dentro do diretório `/tmp` são removidos automaticamente após uma reinicialização do sistema.

Entre no diretório temporário `/tmp`, onde o arquivo `.deb` foi movido:

```bash
cd /tmp
```

Instale o pacote utilizando o `apt` para que as dependências do script sejam instaladas corretamente:

```bash
sudo apt install ./debian-nvidia-installer_X.X.X_amd64.deb
```

> ⚠️ **Importante:** Não instale utilizando `dpkg -i`, isso fará com que as dependências do script não sejam instaladas e o pacote fique quebrado.

### Opção 3: Construir e instalar manualmente (para usuários avançados)

Clone o repositório localmente no seu computador utilizando o pacote [git](https://packages.debian.org/stable/git):

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

Entre no diretório do repositório clonado:

```bash
cd debian-nvidia-installer
```

Execute o script de build disponível no repositório. Ele irá criar o pacote `.deb` em `./deb_build/debian-nvidia-installer_X.X.X_amd64.deb`:

```bash
./build_deb.sh
```

Para instalar o pacote `.deb`, siga os mesmos passos das opções [Opção 1: Interface Gráfica](#opção-1-interface-gráfica) ou [Opção 2: Terminal](#opção-2-terminal).

# Desinstalação

Para desinstalar corretamente o script e suas dependências, utilize o seguinte comando:

```bash
sudo apt purge --autoremove debian-nvidia-installer
```
