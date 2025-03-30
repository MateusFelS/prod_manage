import { test, expect } from '@playwright/test';

const BASE_URL = process.env.BASE_URL;
const MANAGEMENT_TOKEN = process.env.MANAGEMENT_TOKEN;
const INVALID_TOKEN = process.env.INVALID_TOKEN;

let entryId: string;

test.describe('API - Registro de Corte', () => {
    test('Deve obter a lista de cortes', async ({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=cutRecord`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });
        expect(get_response.status()).toBe(200);
        const data = await get_response.json();
        expect(data.items).toBeInstanceOf(Array);
        expect(data.items.length).toBeGreaterThan(0);
    
        const cutRecord = data.items[0].fields;
        expect(cutRecord).toHaveProperty('code');
        expect(cutRecord).toHaveProperty('pieceAmount');
        expect(cutRecord).toHaveProperty('status');
    })

    test('Deve criar um novo corte e depois deletar', async ({ request }) => {
        // Criar corte
        const post_response = await request.post(BASE_URL, {
            headers: {
                Authorization: `Bearer ${MANAGEMENT_TOKEN}`,
                'Content-Type': 'application/vnd.contentful.management.v1+json',
                'X-Contentful-Content-Type': 'cutRecord'
            },
            data: {
                fields: {
                    code: { 'en-US': 'ABCD' },
                    pieceAmount: { 'en-US': 10 },
                    status: { 'en-US': 'paused' }
                }
            }
        });
    
        const data = await post_response.json();
        console.log('🔍 Resposta da API (Criação):', data);
    
        expect(post_response.status()).toBe(201);
        expect(data.sys).toHaveProperty('id');
    
        entryId = data.sys.id;
    
        // Deletar corte
        const delete_response = await request.delete(`${BASE_URL}/${entryId}`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });
    
        expect(delete_response.status()).toBe(204);
    });
})

test.describe('API - Testes Negativos - Registro de Corte', () => {
    test('Não deve obter a lista de cortes sem token de autenticação', async ({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=cutRecord`, { failOnStatusCode: false });
        expect(get_response.status()).toBe(401);
    });

    test('Não deve obter a lista de cortes com token inválido', async ({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=cutRecord`, {
            headers: { Authorization: `Bearer ${INVALID_TOKEN}` },
            failOnStatusCode: false
        });

        expect(get_response.status()).toBe(401);
    });

    test('Não deve deletar um corte inexistente', async ({ request }) => {
        const fakeEntryId = 'invalidEntry123';
        const delete_response = await request.delete(`${BASE_URL}/${fakeEntryId}`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` },
            failOnStatusCode: false
        });
    
        expect(delete_response.status()).toBe(404);
    });
});
