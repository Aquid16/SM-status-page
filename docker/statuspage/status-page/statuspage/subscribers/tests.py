from django.test import TestCase
from rest_framework.test import APIClient
from django.contrib.auth.models import User
class SubscribersTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='admin', password='admin123')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
    
    def test_subscriber_list_view(self):
        response = self.client.get('/api/subscribers/')
        self.assertEqual(response.status_code, 200)