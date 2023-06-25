/**
 *  SatLabAGH @ AGH UST
 *      @author: Bartosz Rudnicki
 *
 * @file:  FlowGraphHandler.hh
 * @brief: Flow Graph management
 */

#ifndef FLOWGRAPHHANDLER_HH
#define FLOWGRAPHHANDLER_HH

#include <gnuradio/top_block.h>
#include <gnuradio/soapy/sink.h>
#include <gnuradio/blocks/file_source.h>
#include <gnuradio/blocks/null_sink.h>


/*
 * @brief: Manage GR's flowgraph
 *
 * Manage underlying GNURadio flowgraph by initializing gr blocks,
 * connecting them, and starting / stopping flowgraph execution.
 *
 */
class FlowGraphHandler
{
public:
    /* @brief: Setup flowgraph */
    void setup();
    /* @brief: Run flowgraph */
    void run();

private:
    gr::top_block_sptr topBlock;
    gr::soapy::sink::sptr sdrSource;
    gr::blocks::file_source::sptr fileSource;
    gr::blocks::null_sink::sptr sink;
};



#endif /* FLOWGRAPHHANDLER_HH */
