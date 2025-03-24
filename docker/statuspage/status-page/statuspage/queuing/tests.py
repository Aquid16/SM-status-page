from django.test import TestCase
from models import Queue
from django.urls import reverse

class QueueTests(TestCase):

    def setUp(self):
        self.queue_data = {'name': 'Processing Queue'}
        self.queue = Queue.objects.create(**self.queue_data)

    def test_create_queue(self):
        queue = Queue.objects.create(name="New Queue")
        self.assertEqual(queue.name, "New Queue")

    def test_queue_api(self):
        url = reverse('queuing:queue_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_queue_detail(self):
        url = reverse('queuing:queue', kwargs={'pk': self.queue.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
