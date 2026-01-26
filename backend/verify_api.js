// Native fetch in Node 18+

const BASE_URL = 'http://localhost:5000/api';
let tokens = {};
let productIds = {};
let saleId;

async function safeFetch(url, options) {
    const res = await fetch(url, options);
    if (!res.ok) {
        const text = await res.text();
        throw new Error(`Failed ${url}: ${res.status} ${text}`);
    }
    return res.json();
}

async function runVerification() {
    try {
        console.log('--- Starting Verification ---');

        // 1. Seed Users
        console.log('\n--- Seeding Users ---');
        let data = await safeFetch(`${BASE_URL}/auth/seed`, { method: 'POST' });
        console.log('Seeded users:', data.length);

        // 2. Login as Warehouse
        console.log('\n--- Login as Warehouse ---');
        data = await safeFetch(`${BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'ware@test.com', password: '123' })
        });
        tokens.warehouse = data.token;
        console.log('Warehouse Token obtained');

        // 3. Login as Sales
        console.log('\n--- Login as Sales ---');
        data = await safeFetch(`${BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'sales@test.com', password: '123' })
        });
        tokens.sales = data.token;
        console.log('Sales Token obtained');

        // 4. Create Product (Warehouse)
        console.log('\n--- Create Product ---');
        data = await safeFetch(`${BASE_URL}/products`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${tokens.warehouse}`
            },
            body: JSON.stringify({
                name: "Red Balloon",
                category: "Balloon",
                size: "Small",
                fruitQuantity: 0,
                unitType: "PIECE",
                currentStock: 100,
                shelfLocation: "A-1",
                price: 10
            })
        });
        productIds.balloon = data._id;
        console.log('Created Product:', data.name, 'ID:', data._id);

        // 5. Create Sale (Sales)
        console.log('\n--- Create Sale ---');
        data = await safeFetch(`${BASE_URL}/sales`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${tokens.sales}`
            },
            body: JSON.stringify({
                items: [{
                    product: productIds.balloon,
                    productName: "Red Balloon",
                    quantity: 5,
                    unitType: "PIECE"
                }],
                isCredit: false
            })
        });
        saleId = data._id;
        console.log('Sale Created. Total:', data.totalAmount);

        // 6. Verify Stock Update
        console.log('\n--- Verify Stock Update ---');
        data = await safeFetch(`${BASE_URL}/products`, {
            headers: { 'Authorization': `Bearer ${tokens.sales}` }
        });
        const p = data.find(p => p._id === productIds.balloon);
        if (p.currentStock === 95) {
            console.log('SUCCESS: Stock updated to 95');
        } else {
            console.error('FAILURE: Stock is', p.currentStock);
        }

        // 7. Login Picker & Check Orders
        console.log('\n--- Picker Check ---');
        data = await safeFetch(`${BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'picker@test.com', password: '123' })
        });
        tokens.picker = data.token;

        data = await safeFetch(`${BASE_URL}/picker/orders`, {
            headers: { 'Authorization': `Bearer ${tokens.picker}` }
        });
        console.log('Pending Orders:', data.length);
        if (data.length > 0 && data[0]._id === saleId) {
            console.log('SUCCESS: Order found by picker');

            // Mark prepared
            const updated = await safeFetch(`${BASE_URL}/picker/orders/${saleId}/prepare`, {
                method: 'PUT',
                headers: { 'Authorization': `Bearer ${tokens.picker}` }
            });
            console.log('Order status:', updated.status, 'IsPrepared:', updated.isPrepared);
        } else {
            console.error('FAILURE: Order not found');
        }

        // 8. Reports (Accountant)
        console.log('\n--- Accountant Report ---');
        data = await safeFetch(`${BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'acc@test.com', password: '123' })
        });
        tokens.accountant = data.token;

        data = await safeFetch(`${BASE_URL}/reports/daily`, {
            headers: { 'Authorization': `Bearer ${tokens.accountant}` }
        });
        console.log('Daily Report:', JSON.stringify(data, null, 2));

        console.log('\n--- VERIFICATION COMPLETE ---');

    } catch (error) {
        console.error('Verification Error:', error.message);
    }
}

runVerification();
