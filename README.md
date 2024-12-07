# ExCommerce
ExCommerce is an ecommerce platform built with a focus on real-time activity. For example:

## From a partner standpoint
- Real time updates allow shop owners to trak stock levels more accurately, reducing risk of backorders, leading to better customer satisfaction and more efficient operations.
- Surge pricing: prices can be adjusted instantly based on demand, competitor pricing, or other market factors, leading to increased pricing.
- Real-time chat and support features enable shop owners to address customer service questions promptly, potentially increasing sales and customer loyalty.

## From a customer standpoint
- If partners have a limited inventory of products, and a user adds one of this product to their cart, the site must reflect, in real time, the updated inventory, so that other users cannot add the product to their cart and result in backorders.
- Having real-time metrics of the number of users with a particular product in their cart helps prompt users to complete checkout. Knowledge that there is only a certain number of inventory left, and X number of users have their item in the cart, drives users to checkout faster with the knowledge that if they do not act now, the X users may check out and remove the item from their immediate reach.
- Live order status: users should know, in real-time, at what stage their order is being fulfilled.

## Backend
The ExCommerce platform runs Elixir and Phoenix with a GraphQL API. Phoenix also provides GraphQL subscriptions via Websockets.

## Frontend
On the frontend, ExCommerce is running a Nuxt app.

## Getting Started

ExCommerce is containerized; after installing [Docker Compose](https://docs.docker.com/compose/), you should have everything you need to run locally. To start the container:

```sh
docker compose up -d
```

After the container boots up, if you want to run a similar environment as staging or production environments, edit your `/etc/hosts` file and add the following:

```sh
# /etc/hosts

127.0.0.1    api.excommerce.test
127.0.0.1    excommerce.test
```

## Running tests
Tests run as part of CI. To run them manually, here's how to do it.

### Backend

```sh
docker compose exec -e MIX_ENV=test backend mix test
```

### Frontend

```sh
docker compose exec frontend npm run test
```
