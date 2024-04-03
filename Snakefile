rule targets:
    input:
        "images/arthropoda.zip",
        "data/islands_shp/municipios.shp",
        "data/islands_shp/eennpp.shp",
        "data/gran_canaria_shp/gc_muni.shp",
        "data/gran_canaria_shp/gc_pne.shp",
        "data/coord_invertebrates.tsv",
        "data/coord_plantae.tsv",
        "index.html"

rule download_images:
    input:
        bash_script = "code/01download_images.bash"
    output:
        "images/arthropoda.zip"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        bash {input.bash_script}
        """

rule download_canary_islands_shp:
    input:
        bash_script = "code/02canary_islands_idecanarias.bash"
    output:
        "data/islands_shp/municipios.shp",
        "data/islands_shp/eennpp.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        bash {input.bash_script}
        """

rule process_canary_islands_shp:
    input:
        python_script = "code/03process_canary_island.py",
        shp_muni = "data/islands_shp/municipios.shp",
        shp_pne = "data/islands_shp/eennpp.shp"
    output:
        "data/gran_canaria_shp/gc_muni.shp",
        "data/gran_canaria_shp/gc_pne.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        mkdir -p data/gran_canaria_shp/
        python {input.python_script}
        """

rule process_exif_images:
    input:
        r_script = "code/04process_exif.R",
        files = "images/arthropoda.zip"
    output:
        "data/coord_invertebrates.tsv",
        "data/coord_plantae.tsv"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.r_script}
        """  

rule interactive_map_invertebrates:
    input:
        rmd = "index.Rmd",
        r_script = "code/05plot_invertebrates.R",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp", 
        species_founded = "data/coord_invertebrates.tsv"
    output:
        "index.html"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}')"
        """  