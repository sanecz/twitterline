use strict;
use warnings;
use WWW::Curl::Easy;
use URI::Escape;
use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(hmac_sha1);
use MIME::Base64;

my $url = "https://userstream.twitter.com/1.1/user.json";
my $oauth_consumer_key = YOUR_KEY;
my $oauth_token = YOUR_KEY;
my $consumer_secret = YOUR_KEY;
my $token_secret = YOUR_KEY;

sub create_header {
    my %hash = (
        "oauth_consumer_key" => $oauth_consumer_key,
        "oauth_nonce" => md5_hex(time),
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_timestamp" => time,
        "oauth_token" => $oauth_token,
        "oauth_version" => "1.0",
        "with" => "followings",
        );
    my $header;
    my $n = keys %hash;
    for (sort (keys(%hash))) {
        $header .= "$_=$hash{$_}";
        $header .= "&" if --$n;
    }

    sub create_sign_base_str {
        my $sign_key = "$consumer_secret&$token_secret";
        my $sign_str = "GET&".uri_escape($url)."&".uri_escape($header);
        return uri_escape(encode_base64(hmac_sha1($sign_str, $sign_key), ""));
    }
    $hash{"oauth_signature"} = create_sign_base_str();
    delete($hash{"with"});
    $header = "Authorization: OAuth ";
    $n = keys %hash;
    for (sort (keys(%hash))) {
        $header .= "$_=\"$hash{$_}\"";
        $header .= ", " if --$n;
    }
    return $header;
}

sub write_cb {
    my ($data, $ptr) = @_;
    print "---> $data";
    return length($data);
}

sub fetch_data {
    my $curl = WWW::Curl::Easy->new;
    my $header = create_header();
    $curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
    $curl->setopt(CURLOPT_URL(), "$url?with=followings");
    $curl->setopt(CURLOPT_HTTPHEADER(), [$header]);
    $curl->setopt(CURLOPT_WRITEFUNCTION, \&write_cb);
    my $response;
    $curl->setopt(CURLOPT_WRITEDATA(), \$response);
    my $retcode = $curl->perform;
}

fetch_data();
