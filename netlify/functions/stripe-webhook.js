const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

// Admin-Client mit Service-Role (darf alles)
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

exports.handler = async (event, context) => {
  const sig = event.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let stripeEvent;

  try {
    stripeEvent = stripe.webhooks.constructEvent(event.body, sig, webhookSecret);
  } catch (err) {
    console.error(`Webhook Error: ${err.message}`);
    return { statusCode: 400, body: `Webhook Error: ${err.message}` };
  }

  if (stripeEvent.type === 'checkout.session.completed' || stripeEvent.type === 'invoice.payment_succeeded') {
    let session, subscriptionId, customerId, userId;

    if (stripeEvent.type === 'checkout.session.completed') {
        session = stripeEvent.data.object;
        subscriptionId = session.subscription;
        customerId = session.customer;
        userId = session.client_reference_id;
    } else {
        const invoice = stripeEvent.data.object;
        subscriptionId = invoice.subscription;
        customerId = invoice.customer;
    }

    if (subscriptionId) {
        try {
            const subscription = await stripe.subscriptions.retrieve(subscriptionId);
            
            // Wenn UserId fehlt (bei Invoice), aus Metadaten holen
            if (!userId && subscription.metadata && subscription.metadata.supabase_user_id) {
                userId = subscription.metadata.supabase_user_id;
            }

            // Status bestimmen
            const status = subscription.status; // 'active', 'past_due', etc.

            if (userId) {
                console.log(`Update Supabase User ${userId}: Status ${status}`);
                
                // --- HIER IST DIE ÄNDERUNG FÜR MOOD TRACKER ---
                // Wir schreiben in die Tabelle 'subscriptions', nicht in auth metadata
                const { error } = await supabaseAdmin
                  .from('subscriptions')
                  .upsert({
                    user_id: userId,
                    stripe_customer_id: customerId,
                    status: status,
                    plan_type: 'pro', // oder dynamisch aus priceId
                    updated_at: new Date()
                  });

                if (error) {
                    console.error('Supabase DB Error:', error);
                } else {
                    console.log('Supabase Tabelle erfolgreich aktualisiert!');
                }
            }
        } catch (err) {
            console.error('Fehler:', err);
        }
    }
  }
  
  // TODO: Handle 'customer.subscription.deleted' (Kündigung/Ablauf) -> Status auf 'canceled' setzen

  return { statusCode: 200, body: 'Received' };
};