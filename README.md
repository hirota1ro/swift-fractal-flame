# Fractal Flame Utilities

<img width="512" alt="c-0001-0002" src="https://user-images.githubusercontent.com/45020018/169014777-af471ad8-6fb0-4534-b6db-0b09be0eed63.png">

Help
```
FractalFlame -?
```

Create image
```
FractalFlame ~/tmp/good.ffdoc -o ~/Downloads/good.png
```

Create high density image
```
FractalFlame ~/tmp/fine.ffdoc -N 200000 -w 512 -d 8 -o ~/Downloads/fine.png
```

Random search
```
FractalFlame search ~/tmp/seed.ffdoc -o ~/tmp/found.ffdoc
```

Search mutations from base element
```
FractalFlame search ~/tmp/base.ffdoc --use-base-element -o ~/tmp/mutation.ffdoc
```

Interpolation
```
FractalFlame interpolate ~/tmp/ends.ffdoc -o ~/tmp/inter.ffdoc
```

Expand variation
```
FractalFlame expand-variation ~/tmp/single.ffdoc -o ~/tmp/varia.ffdoc
```

Export as csv (for spreadsheet)
```
FractalFlame export ~/tmp/found.ffdoc -o ~/Downloads/ff.csv
```

Visualize Variation
```
FractalFlame visualize-variation ~/tmp/ex.ffdoc -o ~/Downloads/ff-v.png
```

Visualize Affine
```
FractalFlame visualize-affine ~/tmp/rnd.ffdoc -o ~/Downloads/ff-a.png
```
