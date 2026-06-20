<?php

return [
    // So'm paid to the user for every 1 kg of accepted waste.
    'price_per_kg' => (int) env('ARINDI_PRICE_PER_KG', 300),

    // Minimum balance (so'm) required before a user can request a withdrawal.
    'min_withdrawal' => (int) env('ARINDI_MIN_WITHDRAWAL', 15000),

    // Supported waste categories. Only `pochoq` is active at launch.
    'categories' => [
        'pochoq' => ['active' => true,  'label' => "Po'choq"],
        'botilka' => ['active' => false, 'label' => 'Bo\'tilka'],
        'plasmassa' => ['active' => false, 'label' => 'Plasmassa'],
        'maklatura' => ['active' => false, 'label' => 'Maklatura'],
    ],
];
