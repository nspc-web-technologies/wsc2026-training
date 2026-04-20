<?php

$logo1 = imagecreatefromjpeg('./original.jpg');
imagefilter($logo1, IMG_FILTER_PIXELATE, $_GET['cell_size'] ?? 50);
header('Content-Type: image/jpeg');
imagejpeg($logo1);
