# TownGeneratorOS-Reduc

A development fork of [Watabou's Medieval Fantasy City Generator](https://github.com/watabou/TownGeneratorOS), originally written by Oleg Dolya. This branch is maintained and extended by **TABARC-Code**. The original application is also available [on itch.io](https://watabou.itch.io/medieval-fantasy-city-generator).

The published source is an earlier version of the original generator. The later application includes features that weren't released in that source tree.

## What's here

- A procedural settlement layout with streets, wards, fortifications and countryside.
- Historical and fantasy culture presets with different architectural layouts.
- Settlement origins including mining and timber camps, ports, fortified waystations and monasteries.
- Seeded terrain elevation, connected coastal water, river courses, piers, road crossings, outlying hamlets and older wall outlines.
- Settlement economies which influence the siting of docks, workshops, mines, markets and military buildings.
- Named districts, SVG maps and JSON containing ward geometry, roads, bridges, gates, walls and economic metadata.

**Style:** Click to cycle cultures. Shift-click to cycle settlement origins. The same controls are available through URL parameters such as `?size=15&seed=1739&culture=viking&origin=fishing_village`. On devices without a Shift key, use the URL to select an origin.

## Build

The project uses Haxe, OpenFL, Lime and msignal. The dependency versions remain recorded in `project.xml` until compatibility with newer releases is checked. Install the required libraries using `haxelib`, then run:

```sh
haxelib run lime test html5
```

To run the source checks:

```sh
python3 scripts/check_integrity.py
```

Once Haxe and the pinned libraries are installed, run the checks and the basic generator regression cases. Without Haxe, this command runs the Python checks but exits with status 2 to indicate the incomplete validation:

```sh
./scripts/run_checks.sh
```

The optional full matrix covers every culture and origin at five settlement sizes. It is considerably slower:

```sh
./scripts/run_checks.sh full
```

With the OpenFL and msignal libraries installed, the regression entry point can be run using Haxe:

```sh
haxe -D debug -cp Source -cp tests -lib lime -lib openfl -lib msignal -main Regression --interp
```

The regression cases cover geometry, noise across negative coordinates, weighted routes, adjacency, waterfront classification, crossing geometry, economic metadata and repeatable settlement seeds. The economy values are relative siting weights; they aren't an economic simulation. Districts without buildings are marked as undeveloped, rather than housing.

To compile the actual application as well as running the tests:

```sh
haxelib run lime build html5
```

## Automated checks

The `Checks` workflow runs the source checks, Haxe regression cases and HTML5 build on pushes and pull requests. Once the build succeeds, the HTML5 files are available as a workflow artifact. It uses Haxe 4.3.7 with the library versions in `project.xml`. A passing build is required before treating the updated source as ready for release.

## Licence and credits

The original TownGeneratorOS source was released under **GNU GPL version 3**. That licence remains in [`LICENSE`](LICENSE). Keep the original notices when copying or adapting source from this project or other forks. TABARC-Code maintains the changes in this repository; the upstream source and its authorship remain credited to Watabou.
