rule targets:
    input:
        "images/flora_vascular.zip",
        "images/invertebrados.zip",
        "data/islands_shp/municipios.shp",
        "data/islands_shp/eennpp.shp",
        "data/jardin_botanico.kml",
        "data/gran_canaria_shp/gc_muni.shp",
        "data/gran_canaria_shp/gc_pne.shp",
        "data/gran_canaria_shp/jardin_botanico.shp",
        "data/coord_invertebrates.tsv",
        "data/coord_plantae.tsv",
        "index.html",
        "invertebrates.html",
        "flora.html",
        "data.html",
        "figures/GC_mapa.png",
        "figures/n_plantae_metazoa.png",

rule download_images:
    input:
        bash_script = "code/01download_images.bash"
    output:
        "images/flora_vascular.zip",
        "images/invertebrados.zip"
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

rule download_jardin_botanico:
    input:
        bash_script = "code/08download_jarbot.bash"
    output:
        "data/jardin_botanico.kml"
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
        shp_pne = "data/islands_shp/eennpp.shp",
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

rule process_jardin_botanico_kml:
    input:
        r_script = "code/09process_jardin_botanico.R",
        kml_jarbot = "data/jardin_botanico.kml"
    output:
        "data/gran_canaria_shp/jardin_botanico.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.r_script}
        """

rule process_exif_images:
    input:
        r_script = "code/04process_exif.R",
        fv_files = "images/flora_vascular.zip",
        ai_files = "images/flora_vascular.zip"
    output:
        "data/coord_invertebrates.tsv",
        "data/coord_plantae.tsv"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.r_script}
        """  
rule figures_and_stats:
    input:
        script_r = "code/07statistics.R",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp",
        invertebrates = "data/coord_invertebrates.tsv",
        plantae = "data/coord_plantae.tsv" 
    output:
        "figures/GC_mapa.png",
        "figures/n_plantae_metazoa.png",
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.script_r}
        """

rule webpage_html:
    input:
        rmd_index = "index.Rmd",
        rmd_invertebrates = "invertebrates.Rmd",
        rmd_flora = "flora.Rmd",
        rmd_data = "data.Rmd",
        r_script_invertebrates = "code/05plot_invertebrates.R",
        r_script_flora = "code/06plot_flora.R",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp", 
        jarbot = "data/gran_canaria_shp/jardin_botanico.shp",
        invertebrates = "data/coord_invertebrates.tsv",
        plantae = "data/coord_plantae.tsv", 
        gc_map_png = "figures/GC_mapa.png",
        n_plantae_metazoa_png = "figures/n_plantae_metazoa.png",
    output:
        "index.html",
        "invertebrates.html",
        "flora.html",
        "data.html"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd_index}')"
        R -e "library(rmarkdown); render('{input.rmd_invertebrates}')"
        R -e "library(rmarkdown); render('{input.rmd_flora}')"
        R -e "library(rmarkdown); render('{input.rmd_data}')"
        """  

