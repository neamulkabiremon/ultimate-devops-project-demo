import unittest
from unittest.mock import MagicMock, patch
from recommendation_server import RecommendationService
from demo_pb2 import ListRecommendationsRequest, ListRecommendationsResponse


class RecommendationServiceTest(unittest.TestCase):

    def setUp(self):
        # Inject logger and rec_svc_metrics manually since they aren't globally exposed
        import recommendation_server
        recommendation_server.logger = MagicMock()
        recommendation_server.rec_svc_metrics = {
            "app_recommendations_counter": MagicMock()
        }

    @patch("recommendation_server.get_product_list")
    def test_excludes_input_products_and_limits_count(self, mock_get_products):
        mock_get_products.return_value = ["prod3", "prod4", "prod5"]

        service = RecommendationService()
        request = ListRecommendationsRequest(product_ids=["prod1", "prod2"])
        context = MagicMock()

        response: ListRecommendationsResponse = service.ListRecommendations(request, context)

        self.assertIsInstance(response, ListRecommendationsResponse)
        self.assertEqual(response.product_ids, ["prod3", "prod4", "prod5"])
        self.assertNotIn("prod1", response.product_ids)
        self.assertNotIn("prod2", response.product_ids)

    @patch("recommendation_server.get_product_list")
    def test_handles_empty_input(self, mock_get_products):
        mock_get_products.return_value = ["prod1", "prod2"]

        service = RecommendationService()
        request = ListRecommendationsRequest(product_ids=[])
        context = MagicMock()

        response = service.ListRecommendations(request, context)

        self.assertEqual(response.product_ids, ["prod1", "prod2"])

    @patch("recommendation_server.get_product_list")
    def test_handles_empty_catalog(self, mock_get_products):
        mock_get_products.return_value = []

        service = RecommendationService()
        request = ListRecommendationsRequest(product_ids=["prod1"])
        context = MagicMock()

        response = service.ListRecommendations(request, context)

        self.assertEqual(response.product_ids, [])


if __name__ == '__main__':
    unittest.main()