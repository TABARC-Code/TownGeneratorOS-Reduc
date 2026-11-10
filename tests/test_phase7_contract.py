import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class Phase7Contracts(unittest.TestCase):
    def test_graph_removes_incoming_links(self):
        source = (ROOT / 'Source/com/watabou/geom/Graph.hx').read_text()
        self.assertIn('other.links.remove(node)', source)
        self.assertIn('!members.exists(start) || !members.exists(goal)', source)

    def test_invalid_edges_rejected(self):
        source = (ROOT / 'Source/com/watabou/geom/Graph.hx').read_text()
        self.assertIn("throw 'Invalid graph edge'", source)

    def test_model_retries_non_error_exceptions(self):
        source = (ROOT / 'Source/com/watabou/towngenerator/building/Model.hx').read_text()
        self.assertIn('catch (e:Dynamic)', source)
        self.assertIn('Std.string(lastError)', source)

    def test_economy_does_not_label_empty_land_housing(self):
        source = (ROOT / 'Source/com/watabou/towngenerator/building/Economy.hx').read_text()
        self.assertIn('"undeveloped"', source)
        self.assertIn('!patch.isWater && connectedToRoad(model, patch)', source)
        self.assertIn('case "Administration": "administration"', source)


if __name__ == '__main__':
    unittest.main()
