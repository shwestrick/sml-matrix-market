`matrix_urls.txt` contains a variety of (arbitrarily chosen, somewhat
randomly from the website) SuiteSparse download links.

```
$ (source venv/bin/activate && python3 download-all.py)
```

```
$ for path in $(find . -name *.mtx); do ... $path; done
```
