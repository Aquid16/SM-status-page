from django.test import TestCase
from models import Subscriber
from django.urls import reverse

class SubscriberTests(TestCase):

    def setUp(self):
        self.subscriber_data = {'email': 'test@example.com'}
        self.subscriber = Subscriber.objects.create(**self.subscriber_data)

    def test_create_subscriber(self):
        subscriber = Subscriber.objects.create(email="newsubscriber@example.com")
        self.assertEqual(subscriber.email, "newsubscriber@example.com")

    def test_subscriber_api(self):
        url = reverse('subscribers:subscriber_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_subscriber_detail(self):
        url = reverse('subscribers:subscriber', kwargs={'pk': self.subscriber.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
