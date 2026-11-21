rule targets:
    input:
        "data/species/raw/raw_dropbox_links_metazoa_content.tsv",
        "data/species/raw/raw_dropbox_links_plantae_content.tsv",
        "data/species/raw/raw_dropbox_links_metazoa_protected_content.tsv",
        "data/species/raw/raw_dropbox_links_plantae_protected_content.tsv",
        "data/islands_shp/municipios.shp",
        "data/islands_shp/eennpp.shp",
        "data/biota/raw/biota_species.csv",
        "data/biota/raw/centinela_species.csv",
        "data/gran_canaria_shp/gc_muni.shp",
        "data/gran_canaria_shp/gc_pne.shp", 
        "data/gran_canaria_shp/gc_zec.shp",
        "data/gran_canaria_shp/gc_grid_empty.shp",
        "data/biota/processed/biota_data_processed.tsv",
        "data/species/processed/coord_species.tsv",
        "data/gran_canaria_shp/protected_species_layer.shp",
        "data/gran_canaria_shp/processed/temp_protected_species.csv",
        "data/gran_canaria_shp/processed/protected_species_layer.shp",
        "data/species/processed/species_data_base.csv",
        "data/species/gran_canaria_shp/processed/species_data_base.shp",
        "figures/GC_mapa.png",
        "figures/n_plantae_metazoa.png",
        "figures/n_category_invertebrates.png",
        "figures/n_category_plantae.png",
        "index.html",
        "species.html",
        "data.html",

rule download_images:
    input:
        r_script = "code/R/01download_images.R",
        metadata_metazoa = "metadata/dropbox_links_metazoa.csv",
        metadata_plantae = "metadata/dropbox_links_plantae.csv",
        metadata_metazoa_protected = "metadata/dropbox_links_metazoa_protected.csv",
        metadata_plantae_protected = "metadata/dropbox_links_plantae_protected.csv"
    output:
        "data/species/raw/raw_dropbox_links_metazoa_content.tsv",
        "data/species/raw/raw_dropbox_links_plantae_content.tsv",
        "data/species/raw/raw_dropbox_links_metazoa_protected_content.tsv",
        "data/species/raw/raw_dropbox_links_plantae_protected_content.tsv"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        mkdir -p data/species data/species/raw/ data/species/processed/  
        Rscript {input.r_script}
        """

rule download_canary_islands_shp:
    input:
        bash_script = "code/bash/01canary_islands_idecanarias.bash"
    output:
        "data/islands_shp/municipios.shp",
        "data/islands_shp/eennpp.shp",
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        bash {input.bash_script}
        """
 
rule download_biota_data:
    input:
        bash_script = "code/bash/03download_biota_data.sh"
    output:
        "data/biota/raw/biota_species.csv", 
        "data/biota/raw/centinela_species.csv" 
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        bash {input.bash_script}
        """
 
rule process_canary_islands_shp:
    input:
        python_script = "code/python/01process_canary_island.py",
        shp_muni = "data/islands_shp/municipios.shp",
        shp_pne = "data/islands_shp/eennpp.shp",
    output:
        "data/gran_canaria_shp/gc_muni.shp",
        "data/gran_canaria_shp/gc_pne.shp",
        "data/gran_canaria_shp/gc_zec.shp"
        "data/gran_canaria_shp/gc_grid_empty.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        mkdir -p data/gran_canaria_shp/
        python {input.python_script}
        """

rule process_biota_data:
    input:
        r_script = "code/R/08process_biota_data.R",
        biota_file = "data/biota/raw/biota_species.csv"
    output:
        "data/biota/processed/biota_data_processed.tsv" 
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.r_script}
        """

rule process_exif_images:
    input:
        r_script = "code/R/02process_exif.R",
        fv_files ="data/species/raw/raw_dropbox_links_metazoa_content.tsv",
        ai_files ="data/species/raw/raw_dropbox_links_plantae_content.tsv",
        biota_file = "data/biota/processed/biota_data_processed.tsv",
        check_errors_labels = "code/R/03check_errors_labels.R",
        check_centinela = "code/R/11check_centinela.R"
    output:
        "data/species/processed/coord_species.tsv"
    log:
        check_labels = "logs/week_names_label_errors.txt",
        check_centinela = "logs/check_centinela.txt"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.r_script}
        Rscript {input.check_errors_labels} > {log.check_labels}
        Rscript {input.check_centinela} > {log.check_centinela}
        """

rule process_protected_species_and_pne:
    input:
        py_script = "code/python/04protected_species_layer.py",
        r_script = "code/R/12delete_coordinates.R",
        coord_species = "data/species/processed/coord_species.tsv",
        gc_grid_empty = "data/gran_canaria_shp/gc_grid_empty.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp"
    output:
        "data/gran_canaria_shp/protected_species_layer.shp",
        "data/gran_canaria_shp/processed/temp_protected_species.csv",
        "data/gran_canaria_shp/processed/protected_species_layer.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        mkdir -p data/gran_canaria_shp/processed/
        python {input.py_script}
        Rscript {input.r_script}
        """

rule species_tabular_data_base:
    input:
        py_script = "code/python/05create_data_base.py",
        coord_species = "data/species/processed/coord_species.tsv",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp",
        gc_zec_shp = "data/gran_canaria_shp/gc_zec.shp",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp"
    output:
        "data/species/processed/species_data_base.csv",
        "data/species/gran_canaria_shp/processed/species_data_base.shp"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        python {input.py_script}
        """

rule figures_and_stats:
    input:
        script_r = "code/R/09statistics.R",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp",
        species = "data/species/processed/species_data_base.csv"
    output:
        "figures/GC_mapa.png",
        "figures/n_plantae_metazoa.png",
        "figures/n_category_invertebrates.png",
        "figures/n_category_plantae.png"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        Rscript {input.script_r}
        """

rule webpage_html:
    input:
        rmd_index = "index.Rmd",
        rmd_species = "species.Rmd",
        rmd_data = "data.Rmd",
        r_script_process_layers = "code/R/07process_map_layers.R",
        r_script_mapping = "code/R/plot_species.R",
        py_pns_info_script = "code/python/02protected_natural_spaces_info.py",
        count_species_py_script = "code/python/03_count_pne_species.py",
        gc_muni_shp = "data/gran_canaria_shp/gc_muni.shp",
        gc_pne_shp = "data/gran_canaria_shp/gc_pne.shp", 
        species = "data/species/processed/coord_species.tsv",
        pspecies_layer = "data/gran_canaria_shp/processed/protected_species_layer.shp", 
        gc_map_png = "figures/GC_mapa.png",
        n_plantae_metazoa_png = "figures/n_plantae_metazoa.png",
        category_invertebrates_png = "figures/n_category_invertebrates.png",
        category_plantae_png = "figures/n_category_plantae.png",
        tables = "code/R/10tables.R",
    output:
        "index.html",
        "species.html",
        "data.html"
    conda:
        "code/enviroments/env.yml"
    shell:
        """
        R -e "rmarkdown::render('{input.rmd_index}')"
        R -e "rmarkdown::render('{input.rmd_species}')"
        R -e "rmarkdown::render('{input.rmd_data}')"
        """  
