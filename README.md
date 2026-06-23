# utils-bash

Conjunto de utilitários de linha de comando em shell script.

## Instalação

```bash
git clone <url-do-repositorio>
cd utils-bash
./install.sh
```

### Dependências

| Funcionalidade | Pacote |
|----------------|--------|
| Conversão áudio/vídeo | ffmpeg |
| Conversão de documentos | pandoc |
| Download YouTube | yt-dlp |
| Redimensionar imagens | imagemagick |
| Compactar/extrair zip | zip / unzip |
| Compactar/extrair 7z | p7zip-full (opcional) |

## Uso

### Converter arquivos

```bash
utils convert video.mp4 mp3
utils convert video.mp4 mp3 -o audio
utils convert documento.md pdf
utils convert documento.md pdf -o relatorio
utils convert documento.md html
utils convert audio.wav flac
```

### Download YouTube

```bash
utils download -youtube https://youtube.com/watch?v=dQw4w9WgXcQ
utils download -youtube https://youtu.be/dQw4w9WgXcQ -mp3
utils download -youtube https://youtube.com/watch?v=xxx -o meu_video
```

### Redimensionar imagens

```bash
utils resize foto.jpg 800x600
utils resize foto.jpg 800
utils resize foto.jpg x600
utils resize foto.jpg 50%
utils resize foto.jpg 800 -o nova
```

### Compactar

```bash
utils compress pasta/ tar.gz
utils compress pasta/ zip
utils compress pasta/ tar.gz -o backup
utils compress arquivo.txt tar.gz
```

### Extrair

```bash
utils extract arquivo.tar.gz
utils extract arquivo.zip
utils extract arquivo.tar.gz -o destino/
```

### Ajuda

```bash
utils help
utils convert --help
utils download --help
utils resize --help
utils compress --help
utils extract --help
```

## Adicionar novos comandos

1. Crie `modules/meucomando.sh`
2. Defina a função `cmd_meucomando()`
3. Adicione um `case` no `utils`:

```bash
meucomando) shift; source "$DIR/modules/meucomando.sh"; cmd_meucomando "$@" ;;
```

## Estrutura do projeto

```
utils-bash/
├── utils              # Entry point principal
├── install.sh         # Script de instalação
├── lib/
│   └── common.sh      # Funções compartilhadas
├── modules/
│   ├── convert.sh     # Conversão de arquivos
│   ├── download.sh    # Download de mídias
│   ├── resize.sh      # Redimensionamento de imagens
│   ├── compress.sh    # Compactação de arquivos
│   └── extract.sh     # Extração de arquivos
└── README.md
```

## Licença

MIT
