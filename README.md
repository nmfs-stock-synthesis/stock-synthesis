# Stock Synthesis 3.30

Stock Synthesis (SS or SS3) is a generalized age-structured population dynamics model implemented in [ADMB](http://www.admb-project.org/). It is used to assess the effect of fisheries on fish and shellfish stocks while taking into account the influence of environmental factors.

# Table of contents
-   [Citing Stock Synthesis](#citing-stock-synthesis)
-   [Installation](#installation)
-   [How can I learn how to use Stock Synthesis?](#how-can-i-learn-how-to-use-stock-synthesis)
-   [How do I ask questions about Stock Synthesis?](#how-do-i-ask-questions-about-stock-synthesis)
-   [How can I contribute to Stock Synthesis?](#how-can-i-contribute-to-stock-synthesis)
-   [Tools for working with SS](#tools-for-working-with-ss)
-   [Disclaimer](#disclaimer)


## Citing Stock Synthesis

Please cite Stock Synthesis as:

```
Methot, R.D. and Wetzel, C.R. (2013). Stock Synthesis: A biological and statistical
framework for fish stock assessment and fishery management. Fisheries Research, 
142: 86-99. https://doi.org/10.1016/j.fishres.2012.10.012
```

## Installation

Download the latest compiled versions on the [Stock Synthesis Website](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view/5042555) or [Github Releases](https://github.com/nmfs-stock-synthesis/stock-synthesis/releases).

## How can I learn how to use Stock Synthesis?

To learn more about how to use stock synthesis, see the [getting started guide with SS guide](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view_file/7137387). To learn how to build your own models in SS, see the [Develop an SS model guide](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view_file/7137399).

The [SS user manual](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view_file/11684231) provides the complete documentation of SS, while the [helper spreadsheets](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view/978337) are useful cheatsheets that outline inputs necessary for options that are widely used within SS.

## How do I ask questions about Stock Synthesis?

Please look for answers or submit questions to the [Stock Synthesis forums](https://vlab.noaa.gov/web/stock-synthesis/public-forums). Note that an account is required to ask questions on the forums. Questions can also be asked by opening an [issue](https://github.com/nmfs-stock-synthesis/stock-synthesis/issues) in this repository or by emailing nmfs.stock.synthesis@noaa.gov.

## How can I contribute to Stock Synthesis?

Have feature requests or bug reports? Want to contribute code? Please open an [issue](https://github.com/nmfs-stock-synthesis/stock-synthesis/issues) or submit a pull request. For complete details, please see [CONTRIBUTING.md](CONTRIBUTING.md)

This project and everyone participating in it is governed by the [NMFS Fisheries Toolbox Code of Conduct](https://github.com/nmfs-fish-tools/Resources/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Tools for working with SS

As SS usage has grown, so has the number of tools to work with it. These include [repositories on github with the stock-synthesis topic](https://github.com/topics/stock-synthesis) as well as:

- [r4ss](https://github.com/r4ss/r4ss): Create plots of SS output and functions to work with SS in R.
- [ss3diags](https://github.com/jabbamodel/ss3diags): Run advanced diagnostics for SS models.
- [ss3sim](https://github.com/ss3sim/ss3sim): Conduct simulation studies using SS.
- [SSI](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view/5042951): Stock Synthesis Interface, a GUI for developing models and running SS. Links to r4ss.
- [SSMSE](https://github.com/nmfs-fish-tools/SSMSE): Use SS operating models in Management Strategy Evaluation.
- [sa4ss](https://github.com/nwfsc-assess/sa4ss): Create accessible R markdown stock assessment documents with results from SS models. Note this tool is intended for use by analysts within the Northwest and Southwest Fisheries Science Centers currently.
- Data limited tools - Options included Simple Stock Synthesis ([SSS](https://github.com/shcaba/SSS)) and Extended Simple Stock Synthesis ([XSSS](https://github.com/chantelwetzel-noaa/XSSS)), as well as [SS-DL-tool](https://github.com/shcaba/SS-DL-tool), a shiny app that includes XSSS and SSS in its functionality.

Have a tool to work with SS that should be mentioned here? Open an issue or pull request to let us know!

## Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project
code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the
Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub
project will be governed by all applicable Federal law. Any reference to specific commercial products,
processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or
imply their endorsement, recommendation or favoring by the Department of Commerce. The Department
of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to
imply endorsement of any commercial product or activity by DOC or the United States Government.
