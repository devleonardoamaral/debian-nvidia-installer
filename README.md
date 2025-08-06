# debian-nvidia-installer

Instalador de drivers NVIDIA com TUI em Bash
A ferramenta permite instalar drivers NVIDIA no Debian usando uma interface
interativa em modo texto (TUI). Automatiza etapas como instalação de pacotes,
verificação de compatibilidade e configuração do ambiente gráfico.


# Instalação

Você pode instalar o `nvidia-installer` baixando o pacote `.deb` a partir da seção **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** deste repositório.

### Opção 1: Interface gráfica (GUI)

1. Baixe o arquivo `.deb`.
2. Dê **dois cliques** sobre o arquivo.
3. No gerenciador de pacotes do sistema, clique em **“Instalar”**.

> 💡 Compatível com gerenciadores como GDebi, Discover (KDE), GNOME Software, etc.

---

### Opção 2: Terminal (Recomendado)

```bash
# Copia o arquivo para /tmp (diretório temporário) para evitar problemas relacionados a permissões
mv ./nvidia-installer_0.0.1.deb /tmp/
cd /tmp

# Instala o pacote e resolve dependências automaticamente
sudo apt install ./nvidia-installer_0.0.1.deb

# Limpa o arquivo após a instalação (opcional)
rm ./nvidia-installer_0.0.1.deb
```

> 💡 Usar `apt install ./arquivo.deb` garante que dependências sejam instaladas corretamente.

# Desinstalação

```bash
# Remove o pacote e suas dependências
sudo apt remove nvidia-installer
```

# Como compilar manualmente

1. Clone este repositório:

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

2. Compile o pacote `.deb` com as permissões corretas:

```bash
dpkg-deb --build --root-owner-group debian-nvidia-installer
```

> 💡 A opção `--root-owner-group` garante que todos os arquivos dentro do pacote tenham proprietário e grupo `root`, conforme esperado para pacotes Debian.

3. O arquivo `debian-nvidia-installer.deb` será gerado na pasta atual, pronto para instalação.
