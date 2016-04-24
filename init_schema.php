#!/usr/bin/env php
<?php

$ttrss_path = $argv[1];

$config = array();

if (getenv('DB_TYPE') !== false) {
	$config['DB_TYPE'] = getenv('DB_TYPE');
} else {
	error('DB_TYPE not found!');
}

if (getenv('DB_HOST') !== false) {
	$config['DB_HOST'] = env('DB_HOST');
} else {
	error('DB_HOST not found!');
}

if (getenv('DB_PORT') !== false) {
	$config['DB_PORT'] = env('DB_PORT');
} else {
	error('DB_PORT not found!');
}

if (getenv('DB_NAME') !== false) {
	$config['DB_NAME'] = env('DB_NAME');
} else {
	error('DB_NAME not found!');
}

if (getenv('DB_USER') !== false) {
	$config['DB_USER'] = env('DB_USER');
} else {
	error('DB_USER not found!');
}

if (getenv('DB_PASS') !== false) {
	$config['DB_PASS'] = env('DB_PASS');
} else {
	error('DB_PASS not found!');
}

echo 'This script will try to create tt-rss schema (if needed)' . PHP_EOL;
echo '  - ' . $config['DB_TYPE'] . ' on ' . $config['DB_HOST'] . ':' . $config['DB_PORT'] . PHP_EOL;
echo '  - Database    : ' . $config['DB_NAME'] . PHP_EOL;
echo '  - User        : ' . $config['DB_USER'] . PHP_EOL;
//echo '  - Pass        : ' . $config['DB_PASS'] . PHP_EOL;
echo '  - ttrss path  : ' . $ttrss_path . PHP_EOL;
$schema_path = $ttrss_path . '/schema/ttrss_schema_' . $config['DB_TYPE'] . '.sql';
echo '  - schema path : ' . $schema_path . PHP_EOL;

if (dbcheck($config)) {
	echo 'Database login created and confirmed' . PHP_EOL;
	$pdo = dbconnect($config);
	try {
		$pdo->query('SELECT 1 FROM ttrss_feeds');
		// reached this point => table found, assume db is complete
	}
	catch (PDOException $e) {
		echo 'Database table not found, applying schema... ' . PHP_EOL;
		$schema = file_get_contents($schema_path);
		//pg_query($conn, "BEGIN; COMMIT;\n" . file_get_contents($filename));
		$schema = preg_replace('/--(.*?);/', '', $schema);
		$schema = preg_replace('/[\r\n]/', ' ', $schema);
		$schema = trim($schema, ' ;');
		foreach (explode(';', $schema) as $stm) {
			$pdo->exec($stm);
		}
		unset($pdo);
	}
} else {
	error('Database login failed!');
}

function env($name, $default = null)
{
	$v = getenv($name) ?: $default;
	if ($v === null) {
		error('The env ' . $name . ' does not exist');
	}
	return $v;
}

function error($text)
{
	echo 'Error: ' . $text . PHP_EOL;
	exit(1);
}

function dbconnect($config)
{
	$dsn=$config['DB_TYPE'] . ':host=' . $config['DB_HOST'] . ';port=' . $config['DB_PORT'] . ';dbname=' . $config['DB_NAME'];
	echo 'url : ' . $dsn . PHP_EOL;
	$pdo = new \PDO($dsn, $config['DB_USER'], $config['DB_PASS']);
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	return $pdo;
}

function dbcheck($config)
{
	try {
		dbconnect($config);
		return true;
	}
	catch (PDOException $e) {
		echo 'dbcheck exception : ',  $e->getMessage(), "\n";
		return false;
	}
}
