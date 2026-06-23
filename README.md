# utils-bash

Conjunto de utilitários de linha de comando em shell script.

## Instalação

```bash
git clone <url-do-repositorio>
cd utils-bash
./install.sh
```

### Dependências

| Funcionalidade | Pacote       |
|----------------|--------------|
| Conversão áudio/vídeo | ffmpeg |
| Conversão de documentos | pandoc |
| Download YouTube | yt-dlp |

## Uso

### Converter arquivos

```bash
utils convert video.mp4 mp3
utils convert documento.md pdf
utils convert documento.md html
utils convert audio.wav flac
```

### Download YouTube

```bash
utils download -youtube https://youtube.com/watch?v=dQw4w9WgXcQ
utils download -youtube https://youtu.be/dQw4w9WgXcQ -mp3
```

### Ajuda

```bash
utils help
utils convert --help
utils download --help
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
│   └── download.sh    # Download de mídias
└── README.md
```

## Licença

MIT
