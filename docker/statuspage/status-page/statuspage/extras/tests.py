from django.test import TestCase
from statuspage.extras.models import Extra
from django.urls import reverse

class ExtraTests(TestCase):

    def setUp(self):
        self.extra_data = {'name': 'Extra Feature'}
        self.extra = Extra.objects.create(**self.extra_data)

    def test_create_extra(self):
        extra = Extra.objects.create(name="New Feature")
        self.assertEqual(extra.name, "New Feature")

    def test_extra_api(self):
        url = reverse('extras:extra_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_extra_detail(self):
        url = reverse('extras:extra', kwargs={'pk': self.extra.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
