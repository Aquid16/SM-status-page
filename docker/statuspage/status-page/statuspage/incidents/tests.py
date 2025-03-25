from django.test import TestCase
from rest_framework.test import APIClient
from django.contrib.auth.models import User

class IncidentsTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='admin', password='admin123')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
    
    def test_incident_list_view(self):
        response = self.client.get('/api/incidents/')
        self.assertEqual(response.status_code, 200)