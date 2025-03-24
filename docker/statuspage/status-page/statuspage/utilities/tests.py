from django.test import TestCase
from statuspage.utilities.models import Utility
from django.urls import reverse

class UtilityTests(TestCase):

    def setUp(self):
        self.utility_data = {'name': 'Utility Service'}
        self.utility = Utility.objects.create(**self.utility_data)

    def test_create_utility(self):
        utility = Utility.objects.create(name="New Utility")
        self.assertEqual(utility.name, "New Utility")

    def test_utility_api(self):
        url = reverse('utilities:utility_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_utility_detail(self):
        url = reverse('utilities:utility', kwargs={'pk': self.utility.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
