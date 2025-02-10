<?php

$requirements = [
    'PHP Version (>=7.4)' => [
        'required' => '7.4',
        'current' => PHP_VERSION,
        'status' => version_compare(PHP_VERSION, '7.4', '>=')
    ],
    'GD Extension' => [
        'required' => 'Installed',
        'current' => extension_loaded('gd') ? 'Installed' : 'Not installed',
        'status' => extension_loaded('gd')
    ],
    'cURL Extension' => [
        'required' => 'Installed',
        'current' => extension_loaded('curl') ? 'Installed' : 'Not installed',
        'status' => extension_loaded('curl')
    ],
    'WebP Support' => [
        'required' => 'Enabled',
        'current' => function_exists('imagewebp') ? 'Enabled' : 'Not enabled',
        'status' => function_exists('imagewebp')
    ]
];

header('Content-Type: text/html; charset=utf-8');
echo '<html><head><title>环境检查</title></head><body>';
echo '<h1>Minecraft Head API 环境检查</h1>';
echo '<table border="1" cellpadding="5" cellspacing="0">';
echo '<tr><th>检查项</th><th>要求</th><th>当前状态</th><th>结果</th></tr>';

$allPassed = true;
foreach ($requirements as $name => $check) {
    $status = $check['status'] ? '✅ 通过' : '❌ 未通过';
    $allPassed = $allPassed && $check['status'];
    echo "<tr>";
    echo "<td>{$name}</td>";
    echo "<td>{$check['required']}</td>";
    echo "<td>{$check['current']}</td>";
    echo "<td>{$status}</td>";
    echo "</tr>";
}

echo '</table>';
echo '<br>';
echo $allPassed 
    ? '<div style="color: green;">✅ 所有检查项通过！API 可以正常运行。</div>'
    : '<div style="color: red;">❌ 存在未通过的检查项，请解决后再运行 API。</div>';
echo '</body></html>'; 