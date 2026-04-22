<?php

$image = imagecreatefromjpeg('./original.jpg');
imagefilter($image, IMG_FILTER_PIXELATE, $_GET['cell_size'] ?? 50, true);
header('Content-Type: image/jpeg');
imagejpeg($image);
