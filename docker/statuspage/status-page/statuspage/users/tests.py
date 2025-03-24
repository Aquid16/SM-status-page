from django.test import TestCase
from models import User
from django.urls import reverse

class UserTests(TestCase):

    def setUp(self):
        self.user_data = {'username': 'testuser', 'password': 'password123'}
        self.user = User.objects.create_user(**self.user_data)

    def test_create_user(self):
        user = User.objects.create_user(username="newuser", password="password123")
        self.assertEqual(user.username, "newuser")

    def test_user_api(self):
        url = reverse('users:user_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_user_detail(self):
        url = reverse('users:user', kwargs={'pk': self.user.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
