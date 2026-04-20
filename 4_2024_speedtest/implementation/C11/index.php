<?php

$image = imagecreatefromjpeg('./original.jpg');
$s = $_GET['cell_size'] ?? 50;
$w = imagesx($image);
$h = imagesy($image);
$small = imagescale($image, $w / $s, $h / $s);
$mosaic = imagescale($small, $w, $h, IMG_NEAREST_NEIGHBOUR);
header('Content-Type: image/jpeg');
imagejpeg($mosaic);
