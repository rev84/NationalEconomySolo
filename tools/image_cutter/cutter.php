<?php

require dirname(__FILE__).'/class.image.php';

define('CARD_DIR',   dirname(__FILE__).'/card');
define('SOURCE_DIR', dirname(__FILE__).'/source');
define('SPOIL_CARD', '_');
define('WIDTH',  140);
define('HEIGHT', 105);

$cutRange = [
  // x, y
  [248, 270],
  [248, 540],
  [248, 810],
  [248, 1080],

  [1323, 270],
  [1323, 540],
  [1323, 810],
  [1323, 1080],
];

$images = [
  'img51.jpg',
  'img54.jpg',
  'img57.jpg',
  'img60.jpg',
  'img63.jpg',
];

$cardnum = [
  0, 0, 2, 3,
  4, 0, 5, 6,
  7, 8, 9, 10,
  11, 12, 13, 15,
  14, 16, 19, 17,
  18, 20, 22, 23,
  24, 25, 26, 28,
  29, 27, 31, 33,
  35, 36, 21, 32,
  30, 34, 0, 0,
];

$count = 0;


foreach ($images as $imgname) {
  foreach ($cutRange as $r) {
    list($x, $y) = $r;
    $thumb = new Image(SOURCE_DIR.'/'.$imgname);
    $thumb->width(WIDTH);
    $thumb->height(HEIGHT);
    $thumb->crop($x, $y);
    $thumb->dir(CARD_DIR);
    $name = $cardnum[$count++];
    $thumb->name($name == 0 ? SPOIL_CARD : $name);
    $thumb->save();
  }
}

// 消費財
$thumb = new Image(SOURCE_DIR.'/'.'img63.jpg');
$thumb->width(WIDTH);
$thumb->height(HEIGHT);
$thumb->crop(1323, 1110);
$thumb->dir(CARD_DIR);
$thumb->name('99');
$thumb->save();

unlink(CARD_DIR.'/'.SPOIL_CARD.'.jpg');