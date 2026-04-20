<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // var_dump($_FILES['files']);
    $name = tempnam(sys_get_temp_dir(), "FOO");
    $zip = new ZipArchive;
    $res = $zip->open($name, ZipArchive::OVERWRITE); /* truncate as empty file is not valid */
    if ($res === TRUE) {
        for ($i = 0; $i < count($_FILES['files']['name']); $i++) {
            $zip->addFile($_FILES['files']['tmp_name'][$i], $_FILES['files']['full_path'][$i]);
        }
        $zip->close();
        header('Content-Type: application/zip');
        header('Content-Disposition: attachment; filename="' . explode('/', $_FILES['files']['full_path'][0])[0] . '.zip"');
        header('Content-Length: ' . filesize($name));
        readfile($name);
        unlink($name);
        exit;
    } else {
        echo 'failed';
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <form action="" method="post" enctype="multipart/form-data">
        <input type="file" name="files[]" id="" webkitdirectory>
        <button type="submit">Compress</button>
    </form>
</body>

</html>