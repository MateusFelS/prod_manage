import { test, expect } from '@playwright/test';

const BASE_URL = process.env.BASE_URL;
const MANAGEMENT_TOKEN = process.env.MANAGEMENT_TOKEN;
const INVALID_TOKEN = process.env.INVALID_TOKEN;

let performanceEntryId: string;

test.describe('API - Performance', () => {
    test('Deve obter a lista de performances', async({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=performance`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });
        expect(get_response.status()).toBe(200);
        const data = await get_response.json();
        expect(data.items).toBeInstanceOf(Array);
        expect(data.items.length).toBeGreaterThan(0);

        const performance = data.items[0].fields;
        expect(performance).toHaveProperty('produced');
        expect(performance).toHaveProperty('employee');
    });

    test('Deve criar um novo registro de performance e depois deletar', async ({ request }) => {
        // Criar performance
        const post_response = await request.post(BASE_URL, {
            headers: {
                Authorization: `Bearer ${MANAGEMENT_TOKEN}`,
                'Content-Type': 'application/vnd.contentful.management.v1+json',
                'X-Contentful-Content-Type': 'performance'
            },
            data: {
                fields: {
                    produced: { 'en-US': 100 },
                    employee: { 'en-US': { sys: { id: 'DHXToEuLi0Re7HgCoVMM2', type: 'Link', linkType: 'Entry' } } }
                }
            }
        });

        const data = await post_response.json();
        console.log('🔍 Resposta da API (Criação):', data);

        expect(post_response.status()).toBe(201);
        expect(data.sys).toHaveProperty('id');

        performanceEntryId = data.sys.id;

        // Deletar performance
        const delete_response = await request.delete(`${BASE_URL}/${performanceEntryId}`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });

        expect(delete_response.status()).toBe(204);
    });
});

test.describe('API - Testes Negativos - Performance', () => {
  
    test('Não deve obter a lista de performances sem token de autenticação', async ({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=performance`, { failOnStatusCode: false });

        expect(get_response.status()).toBe(401);
    });

    test('Não deve obter a lista de performances com token inválido', async ({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=performance`, {
            headers: { Authorization: `Bearer ${INVALID_TOKEN}` },
            failOnStatusCode: false
        });

        expect(get_response.status()).toBe(401);
    });

    test('Não deve deletar um registro de performance inexistente', async ({ request }) => {
        const fakeEntryId = 'invalidEntry123';

        const delete_response = await request.delete(`${BASE_URL}/${fakeEntryId}`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` },
            failOnStatusCode: false
        });

        expect(delete_response.status()).toBe(404);
    });
});
