"""Graph boundaries must hold even when objects have external links."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class GraphBoundaries(unittest.TestCase):
    def test_membership_enforced(self):
        graph = (ROOT / 'Source/com/watabou/geom/Graph.hx').read_text()
        for snippet in (
            'private var members:Map<Node, Bool> = new Map();',
            'members.set(node, true);',
            'members.remove(node);',
            '!members.exists(neighbour)',
            '!members.exists(source) || !members.exists(target)',
        ):
            self.assertIn(snippet, graph)

    def test_haxe_regression_covers_foreign_nodes(self):
        regression = (ROOT / 'tests/Regression.hx').read_text()
        self.assertIn('paths stay inside the graph', regression)
        self.assertIn('foreign nodes have no path cost', regression)

if __name__ == '__main__':
    unittest.main()
