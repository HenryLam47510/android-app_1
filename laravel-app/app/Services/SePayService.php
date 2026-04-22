<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class SePayService
{
    protected $apiUrl;
    protected $apiToken;

    public function __construct()
    {
        $this->apiUrl = config('services.sepay.api_url');
        $this->apiToken = config('services.sepay.api_token');
    }

    public function createPayment($orderId, $amount, $returnUrl)
    {
        $response = Http::withHeaders([
            'Authorization' => "Bearer {$this->apiToken}",
            'Content-Type' => 'application/json',
        ])->post("{$this->apiUrl}/payment/create", [
            'order_id' => $orderId,
            'amount' => $amount,
            'return_url' => $returnUrl,
        ]);

        return $response->json();
    }
}
