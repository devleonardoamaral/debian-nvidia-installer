# debian-nvidia-installer

Instalador de drivers NVIDIA com TUI em Bash
A ferramenta permite instalar drivers NVIDIA no Debian usando uma interface
interativa em modo texto (TUI). Automatiza etapas como instalação de pacotes,
verificação de compatibilidade e configuração do ambiente gráfico.

### Requisitos

* Distribuição **Debian Trixie**
* Arquitetura 64 bits
* Placa gráfica **NVIDIA compatível**
  > Os drivers oficiais da NVIDIA no Debian Trixie não oferecem suporte a [GPUs com arquitetura Fermi ou Kepler](https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/).
  
  > Consulte o [guia do Debian sobre a instalação de drivers legados](https://wiki.debian.org/NvidiaGraphicsDrivers#Tesla_Drivers) se necessário.
* Shell compatível com **Bash**
* Privilégios de administrador (**sudo/root**)

# Como executar

Após a instalação, você pode iniciar o script através do atalho na lista de aplicativos ou através do terminal executando o comando:

```bash
sudo debian-nvidia-installer
```

> ⚠️ **É necessário executar como root**, pois a ferramenta realiza alterações no sistema, como instalação de pacotes e modificação de arquivos de configuração.

# Instalação

Você pode instalar o `debian-nvidia-installer` baixando o pacote `.deb` a partir da seção **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** deste repositório.

### Opção 1: Interface gráfica (GUI)

1. Baixe o arquivo `.deb`.
2. Dê **dois cliques** sobre o arquivo.
3. No gerenciador de pacotes do sistema, clique em **“Instalar”**.

> 💡 Compatível com gerenciadores como GDebi, Discover (KDE), GNOME Software, etc.

### Opção 2: Terminal (Recomendado)

```bash
# Copia o arquivo para /tmp (diretório temporário) para evitar problemas relacionados a permissões
mv ./debian-nvidia-installer_X.X.X.deb /tmp/
cd /tmp

# Instala o pacote e resolve dependências automaticamente
sudo apt install ./debian-nvidia-installer_X.X.X.deb

# Limpa o arquivo após a instalação (opcional)
rm ./debian-nvidia-installer_X.X.X.deb
```

# Desinstalação

```bash
# Remove o pacote e suas dependências
sudo apt remove debian-nvidia-installer
```

# Como empacotar manualmente

1. Clone este repositório:

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

2. Compile o pacote `.deb` com as permissões corretas:

```bash
dpkg-deb --build --root-owner-group debian-nvidia-installer
```

3. O arquivo `debian-nvidia-installer.deb` será gerado na pasta atual, pronto para instalação.
