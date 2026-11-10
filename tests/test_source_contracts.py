"""Source-level checks that work without the Haxe toolchain."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


class SourceContracts(unittest.TestCase):
    def test_generation_retries_clear_references(self):
        model = source("Source/com/watabou/towngenerator/building/Model.hx")
        build = model.split("private function build():Void", 1)[1].split("private function buildWater():Void", 1)[0]
        for field in ("plaza", "citadel", "border", "wall", "oldWall", "topology"):
            self.assertIn(field + " = null;", build)
        for field in ("arteries", "gates", "hamlets", "streets", "roads"):
            self.assertIn(field + " = [];", build)
        self.assertLess(build.index("plaza = null;"), build.index("buildPatches();"))

    def test_export_metadata_comes_from_model(self):
        exporter = source("Source/com/watabou/towngenerator/io/Exporter.hx")
        self.assertNotIn("StateManager.", exporter)
        for field in ("seed", "size", "culture", "origin"):
            self.assertIn("model." + field, exporter)

    def test_hydrology_uses_model_seed(self):
        model = source("Source/com/watabou/towngenerator/building/Model.hx")
        self.assertIn("Hydrology.apply(this, seed);", model)
        self.assertNotIn("Hydrology.apply(this, StateManager.seed", model)

    def test_economy_applied_to_ward_selection(self):
        model = source("Source/com/watabou/towngenerator/building/Model.hx")
        self.assertIn("Economy.hasPreference(wardClass)", model)
        self.assertIn("Economy.score(this, patch, wardClass)", model)

    def test_full_matrix_is_forwarded_to_haxe(self):
        runner = source("scripts/run_checks.sh")
        self.assertIn('if [ "${1:-}" = "full" ]; then', runner)
        self.assertIn('RegressionSuite full', runner)

    def test_road_access_uses_segments(self):
        economy = source("Source/com/watabou/towngenerator/building/Economy.hx")
        geometry = source("Source/com/watabou/geom/Polygon.hx")
        regression = source("tests/Regression.hx")
        self.assertIn("patch.shape.intersectsSegment(road[i - 1], road[i])", economy)
        self.assertIn("public function intersectsSegment(a:Point, b:Point):Bool", geometry)
        self.assertIn('"road crossing without shared vertices"', regression)
        self.assertIn('"parallel road away from plot"', regression)

    def test_export_filename_uses_model_seed(self):
        scene = source("Source/com/watabou/towngenerator/TownScene.hx")
        self.assertEqual(scene.count('"city_" + Model.instance.seed'), 2)
        self.assertNotIn('"city_" + StateManager.seed', scene)

    def test_removed_graph_nodes_unlink_every_neighbour(self):
        graph = source("Source/com/watabou/geom/Graph.hx")
        self.assertIn("var neighbours = [for (node in links.keys()) node];", graph)
        self.assertIn('"node removal clears every reverse link"', source("tests/Regression.hx"))

    def test_graph_order_is_monotonic(self):
        graph = source("Source/com/watabou/geom/Graph.hx")
        regression = source("tests/Regression.hx")
        self.assertIn("private var nextOrder:Int = 0;", graph)
        self.assertIn("node.order = nextOrder++;", graph)
        self.assertIn('"graph node order is never reused"', regression)

    def test_polygon_degenerate_centroids_are_finite(self):
        polygon = source("Source/com/watabou/geom/Polygon.hx")
        regression = source("tests/Regression.hx")
        self.assertIn("if (this.length < 3) return center;", polygon)
        self.assertIn("if (Math.abs(a) < 0.000000001) return center;", polygon)
        self.assertIn('"collinear centroid"', regression)

    def test_ui_restores_settings_on_failed_generation(self):
        style = source("Source/com/watabou/towngenerator/ui/CultureButton.hx")
        size = source("Source/com/watabou/towngenerator/ui/CitySizeButton.hx")
        self.assertIn("StateManager.culture = previousCulture;", style)
        self.assertIn("StateManager.origin = previousOrigin;", style)
        self.assertIn("StateManager.size = previousSize;", size)
        self.assertIn("StateManager.seed = previousSeed;", size)
        self.assertLess(style.index("new Model("), style.index("StateManager.pushParams();"))
        self.assertLess(size.index("new Model("), size.index("StateManager.pushParams();"))

    def test_failed_generation_preserves_previous_model(self):
        model = source("Source/com/watabou/towngenerator/building/Model.hx")
        block = model.split("public function new( nPatches=-1, seed=-1 )", 1)[1].split("private function build():Void", 1)[0]
        self.assertNotIn("instance = null;", block)
        self.assertIn("instance = this;", block)

    def test_debug_validation_runs_in_haxe_tests(self):
        runner = source("scripts/run_checks.sh")
        self.assertEqual(runner.count("haxe -D debug "), 3)
        self.assertIn('callValidate("buildGeometry")', source("Source/com/watabou/towngenerator/building/Model.hx"))

    def test_workflow_uploads_a_build_and_limits_permissions(self):
        workflow = source(".github/workflows/checks.yml")
        self.assertIn("contents: read", workflow)
        self.assertIn("timeout-minutes: 40", workflow)
        self.assertIn("actions/upload-artifact@v4", workflow)
        self.assertIn("Export/html5/bin/", workflow)

    def test_build_workflow_covers_haxe_and_html5(self):
        workflow = source(".github/workflows/checks.yml")
        regression = source("tests/Regression.hx")
        self.assertIn("krdlab/setup-haxe@v2", workflow)
        self.assertIn("sh scripts/run_checks.sh", workflow)
        self.assertIn("haxelib run lime build html5", workflow)
        self.assertIn('parsed.firstElement().nodeName == "svg"', regression)

    def test_licence_and_original_credit_retained(self):
        self.assertTrue(source("LICENSE").startswith("                    GNU GENERAL PUBLIC LICENSE"))
        self.assertIn("Watabou", source("README.md"))


if __name__ == "__main__":
    unittest.main()
