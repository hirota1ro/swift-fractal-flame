# FractalFlame


Help
```
swift run FractalFlame -?
```

Create image
```
swift run FractalFlame ~/tmp/good.ffdoc -o ~/Downloads/good.png
```

Create high density image
```
swift run FractalFlame ~/tmp/fine.ffdoc -N 200000 -w 512 -d 8 -o ~/Downloads/fine.png
```

Random search
```
swift run FractalFlame search ~/tmp/seed.ffdoc -o ~/tmp/found.ffdoc
```

Search mutations from base element
```
swift run FractalFlame search ~/tmp/base.ffdoc --use-base-element -o ~/tmp/mutation.ffdoc
```

Interpolation
```
swift run FractalFlame interpolate ~/tmp/ends.ffdoc -o ~/tmp/inter.ffdoc
```

Expand variation
```
swift run FractalFlame expand-variation ~/tmp/single.ffdoc -o ~/tmp/varia.ffdoc
```

Export as csv (for spreadsheet)
```
swift run FractalFlame export ~/tmp/found.ffdoc -o ~/Downloads/ff.csv
```

Visualize Variation
```
swift run FractalFlame visualize-variation ~/tmp/ex.ffdoc -o ~/Downloads/ff-v.png
```

Visualize Affine
```
swift run FractalFlame visualize-affine ~/tmp/rnd.ffdoc -o ~/Downloads/ff-a.png
```
