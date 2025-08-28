# debian-nvidia-installer

Instalador de drivers NVIDIA com TUI em Bash
A ferramenta permite instalar drivers NVIDIA no Debian usando uma interface
interativa em modo texto (TUI). Automatiza etapas como instalação de pacotes,
verificação de compatibilidade e configuração do ambiente gráfico.

<img src="data/screenshots/main-menu.png">

<div style="display:flex; gap:10px;">
  <img src="data/screenshots/drivers-menu.png" width="394" height="266">
  <img src="data/screenshots/post-installation-menu.png" width="394" height="266">
</div>

### Requisitos

* Distribuição Debian Trixie
* Arquitetura 64 bits
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

Antes de começar, **verifique a versão do script que você baixou do GitHub**.
Substitua `X.X.X` nos comandos a seguir pela versão correta.
Exemplo: se a versão for `0.0.1`, o arquivo será `debian-nvidia-installer_0.0.1.deb`.

> ⚠️ **Importante:** não instale o arquivo diretamente do local de download. Sempre mova para o diretório temporário (`/tmp`) para evitar problemas de permissão.

#### Passo 1 – Mover o arquivo para o diretório temporário

```bash
mv ./debian-nvidia-installer_X.X.X.deb /tmp/
```

Isso move o arquivo `.deb` para o diretório `/tmp`, que é seguro para instalar pacotes sem precisar de permissões especiais.

#### Passo 2 – Entrar no diretório temporário

```bash
cd /tmp
```

O comando `cd` significa “change directory” (mudar de diretório). Aqui você entra na pasta `/tmp` onde o arquivo foi movido.

#### Passo 3 – Instalar o pacote

```bash
sudo apt install ./debian-nvidia-installer_X.X.X.deb
```

#### Passo 4 – Limpar o arquivo após a instalação (opcional)

```bash
rm ./debian-nvidia-installer_X.X.X.deb
```

Isso remove o arquivo `.deb` que não é mais necessário. É opcional, já que todos os arquivos de `/tmp` são excluídos após reiniciar o sistema.

### Opção 3: Construir e instalar manualmente (para usuários avançados)

#### Passo 1 – Clonar o repositório

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

Isso cria uma cópia local do repositório em seu computador.

#### Passo 2 – Construir o pacote `.deb`

```bash
dpkg-deb --build --root-owner-group debian-nvidia-installer
```

* Cria o arquivo `.deb` a partir da pasta do repositório.
* `--root-owner-group` garante permissões compatíveis com o sistema.

#### Passo 3 – Instalar o pacote (mesmos passos da Opção 2)

Use os mesmos passos das opções [Opção 1: Interface Gráfica (GUI)](#opção-1-interface-gráfica) ou [Opção 2: Terminal](#opção-2-terminal). O arquivo gerado, `debian-nvidia-installer.deb`, **não inclui o número da versão**.

# Desinstalação

```bash
sudo apt purge --autoremove debian-nvidia-installer
```
* `sudo` executa o comando como administrador.
* `apt purge` remove o pacote completamente, incluindo seus arquivos de configuração.
* `--autoremove` também remove dependências que não são mais necessárias.